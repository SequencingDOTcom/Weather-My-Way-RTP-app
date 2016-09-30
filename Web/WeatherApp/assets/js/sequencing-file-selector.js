$.fn.sequencingFileSelector = function(options) {
  this.data('sequencingFileSelector', new SequencingFileSelector(this, options));
};

/**
 * Constructor for the sequencing file selector widget.
 *
 * @param formElement
 *   jQuery DOM object of the form element into which the file selector
 *   should report what is selected in this widget
 * @param options
 *   Object of options for the file selector. It supports the following
 *   properties:
 *   - accessToken: oAuth2 access token to use when querying the backend
 *   - serverURL: URL of the backend
 */
SequencingFileSelector = function(formElement, options) {
  options = options || {};
  options = $.extend({
    accessToken: '',
    serverURL: 'https://api.sequencing.com',
    method: 'DataSourceList',
    fileNameElement: $()
  }, options);
  if (!options.accessToken) {
    // We need access token to continue.
    return;
  }
  if (!(options.fileNameElement instanceof $)) {
    options.fileNameElement = $();
  }

  this.formElement = formElement;
  this.options = options;
  this.files = [];
  this.fileTypes = [];

  this.switch = $('<div></div>').addClass('sequencing-file-selector-type-control');
  var button = $('<button name="sample"></button>').addClass('btn').addClass('btn-custom').html('I want to use<br />a sample file');
  button.click(function(e) {
    e.preventDefault();
  });
  this.switch.append(button);
  this.switch.append($('<span></span>').addClass('or').text('or'));
  var button = $('<button name="uploaded"></button>').addClass('btn').addClass('btn-custom').html('I want to use<br />my own file');
  button.click(function(e) {
    e.preventDefault();
  });
  this.switch.append(button);

  var obj = this;
  this.switch.find('button').click(function(e) {
    obj.controlChanged(e);
  });

  this.formElement.before(this.switch);
  this.switch.before($('<p></p>').addClass('sequencing-file-selector-help-text').text('Select one'));

  this.table = $('<table></table>');
  this.table.addClass('sequencing-file-selector').addClass('table').addClass('table-striped').addClass('table-hover');
  var thead = $('<thead></thead>');
  thead.append($('<tr><th class="column-radio-button"></th><th>File name</th></tr>'));
  this.table.append(thead);
  this.table.append($('<tbody></tbody>'));

  this.formElement.after(this.table);
  this.table.wrap($('<div></div>').addClass('table-responsive'));
  this.table.parents('.table-responsive').wrap($('<div></div>').addClass('sequencing-file-selector-table-container').addClass('hidden'));
  this.table.parents('.sequencing-file-selector-table-container')
    .prepend($('<p></p>').addClass('sequencing-file-selector-help-text').html('Select a file from the list below<br /><span class="sequencing-file-selector-help-text-brackets">(The genetic data from the file you select will be used to personalize this app.)</span>'));

  if ($(this.formElement).parents('form').size() > 0) {
    $(this.formElement).parents('form').submit(function() {
      if (!$(obj.formElement).val()) {
        obj.validationClean();
        obj.switch.after($('<p></p>').addClass('error').html('No file selected. Select a file before continuing.'));
        return false;
      }
    });
  }
};

/**
 * Method to populate the table with rows, i.e. with files.
 *
 * @param files
 *   Array of files downloaded from the API, normally those are downloaded
 *   through fetchFiles() method
 */
SequencingFileSelector.prototype.populateFiles = function(files) {
  for (var i = 0; i < files.length; i++) {
    var fileRow = new SequencingFileSelectorRow(this, files[i]);
    this.files.push(fileRow);
    this.table.find('tbody').append(fileRow.html());
  }
};

/**
 * Method to fetch files from the API.
 */
SequencingFileSelector.prototype.fetchFiles = function() {
  var obj = this;
  this.files = [];
  this.unselect();
  this.table.find('tbody').html('');
  this.table.addClass('loading');

  var dataObject = {};
  for (var i = 0; i < this.fileTypes.length; i++) {
    dataObject[this.fileTypes[i]] = 'true';
  }
  $.ajax({
    type: 'GET',
    url: this.options.serverURL + '/' + this.options.method,
    data: dataObject,
    headers: {
      Authorization: "Bearer " + this.options.accessToken,
    },
    success: function(data) {
      if (data.length == 0 && dataObject.uploaded) {
        // If uploaded files of this user are empty, switch to the
        // sample ones.
        obj.switch.find(':input[name=sample]').trigger('click');
        obj.switch.after($('<div></div>').addClass('alert').addClass('alert-info')
          .append($('<p></p>').text("Your Sequencing.com account doesn't appear to have any genetic data."))
          .append($('<p></p>').text("Please go to the Upload Center at Sequencing.com to upload your genetic data. You'll then be able to connect this app with your genetic data."))
          .append($('<p></p>').text("Until then, please use one of the following sample files."))
        );
      }
      obj.populateFiles(data);
      obj.table.removeClass('loading');
    },
  });
};

/**
 * Method to unselect all rows, optionally except for one.
 */
SequencingFileSelector.prototype.unselect = function(except) {
  for (var i = 0; i < this.files.length; i++) {
    if (this.files[i] != except) {
      this.files[i].unselect();
    }
  }
  this.val({});
}

/**
 * Set or get current value of the file selector.
 */
SequencingFileSelector.prototype.val = function(selectedFile) {
  var returnValue;
  if (selectedFile.Id) {
    returnValue = this.formElement.val(selectedFile.Id);
    if (this.options.fileNameElement.size() > 0) {
      for (var i = 0; i < this.files.length; i++) {
        if (this.files[i].file.Id == selectedFile.Id) {
          var name = $('<div></div>').append(this.files[i].fileName());
          name = name.text();

          this.options.fileNameElement.val(name);
        }
      }
    }
    this.validationClean();
  }
  else {
    returnValue = this.formElement.val('');
    if (this.options.fileNameElement.size() > 0) {
      this.options.fileNameElement.val('');
    }
  }
  return returnValue;
};

/**
 * Remove any validation messages, if such exist.
 */
SequencingFileSelector.prototype.validationClean = function() {
  this.switch.siblings('.error').remove();
};

/**
 * Test if the current screen is of any Bootstrap specific size.
 *
 * @param screenSize
 *   Any of the bootstrap specific screen sizes, such as "xs", "sm", "md",
 *   "lg"
 */
SequencingFileSelector.prototype.screenSize = function(screenSize) {
  var div = $('<div></div>').addClass('visible-' + screenSize + '-block');
  div.html('test');
  $('body').append(div);
  var result = div.is(':visible');
  div.remove();
  return result;
};

/**
 * Event listener for a change in the controlling form element.
 *
 * Reload the table with new settings.
 */
SequencingFileSelector.prototype.controlChanged = function(e) {
  this.switch.siblings('.alert').remove();
  this.switch.find('button.active').removeClass('active');
  this.table.parents('.sequencing-file-selector-table-container').removeClass('hidden');

  this.fileTypes = [];

  $(e.target).addClass('active');

  switch ($(e.target).attr('name')) {
    case 'sample':
      this.fileTypes = ['sample'];
      break;

    case 'uploaded':
      this.fileTypes = ['uploaded', 'shared'];
      break;
  }
  this.fetchFiles();
}

/**
 * Constructor to build a table row from a file.
 *
 * @param fileSelector
 *   An instance of Sequencing file selector
 * @param file
 *   File as downloaded from the API
 */
SequencingFileSelectorRow = function(fileSelector, file) {
  this.fileSelector = fileSelector;
  this.file = file;
  this.row = null;
};

/**
 * Get HTML representation of the file, i.e. its table row.
 */
SequencingFileSelectorRow.prototype.html = function() {
  var name = this.fileSelector.formElement.attr('name') + '_button';
  this.button = $('<input type="radio" name="" />');
  this.button.attr('name', name);

  this.row = $('<tr></tr>');
  this.row.append($('<td></td>').addClass('column-radio-button').append(this.button));
  this.row.append($('<td></td>').html(this.fileName()));

  var obj = this;
  this.row.bind('click', function(e) {
    obj.rowClicked(e);
  })

  return this.row;
};

/**
 * Retrieve file name of this file row.
 *
 * Notice: this string may contain HTML mark up.
 */
SequencingFileSelectorRow.prototype.fileName = function() {
  if (this.file.FileCategory == 'Community') {
    var name = this.file.FriendlyDesc1;
    if (this.file.FriendlyDesc2) {
      name += '<span class="sequencing-file-selector-file-description-delimeter hidden-xs"> - </span><span class="sequencing-file-selector-description-2">' + this.file.FriendlyDesc2 + '</span>';
    }
    return name;
  }
  else {
    return this.file.Name;
  }
};

/**
 * Event handler for clicking on a file row.
 */
SequencingFileSelectorRow.prototype.rowClicked = function(e) {
  if (this.row.hasClass('selected')) {
    this.row.removeClass('selected');
    this.fileSelector.unselect();
  }
  else {
    this.fileSelector.unselect(this);
    this.button.prop('checked', true);
    this.row.addClass('selected');
    this.fileSelector.val(this.file);
  }
};

/**
 * Method to unselect this row.
 */
SequencingFileSelectorRow.prototype.unselect = function() {
  this.button.prop('checked', false);
  this.row.removeClass('selected');
};
