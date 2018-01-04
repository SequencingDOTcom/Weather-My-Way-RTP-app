//
//  ForecastLayout.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>



// ============================================================================
// iPad
// ============================================================================
#pragma mark -
#pragma mark iPad

// Gray view 1: Current Temperature
#define kWeatherIconWidthHeight_IPad                190.f
#define kCurrentTemperatureFontSize_IPad            180.f
#define kCurrentTemperatureUnitFontSize_IPad        35.f
#define kCurrentTemperatureUnitBaselineOffset_IPad  105
#define kTodaysTemperatureFontSize_IPad             22.f

// auto layout parameters for Alert Button
#define kGrayView2BottomToExtendedTextBottomWithAlert_IPadPortrait      55.f
#define kGrayView2BottomToExtendedTextBottomWithNoAlert_IPadPortrait    40.f
#define kExtendedTextBottomToGrayView2BottomWithAlert_IPadLandscape     -65.f
#define kExtendedTextBottomToGrayView2BottomWithNoAlert_IPadLandscape   -30.f

// Gray view 4 Forecast 7/10 days
#define kForecastDayName_IPad           14.f
#define kForecastDayTemperature_IPad    14.f

#define kForecast1WidthMultiplier_IPadPortrait  0.133f
#define kForecast1WidthMultiplier_IPadLandscape 0.093f





// ============================================================================
// iPad Pro 12.9"
// ============================================================================
#pragma mark -
#pragma mark iPad Pro 12.9"

// common font sizes
#define kGrayViewTitleFontSize_IPadPro          30.f

// Gray view 1: Current Temperature
#define kWeatherIconWidthHeight_IPadPro                     240.f
#define kCurrentTemperatureFontSize_IPadPro                 250.f
#define kCurrentTemperatureFontSizeLess_IPadPro             230.f
#define kCurrentTemperatureUnitFontSize_IPadPro             50.f
#define kCurrentTemperatureUnitBaselineOffset_IPadPro       150
#define kTodaysTemperatureAndWeatherTypeFontSize_IPadPro    30.f
#define kWindHumidityAndPrecipitationFontSize_IPadPro       25.f

#define kGrayView1TopToContentViewTop_IPadProLandscape                  40.f
#define kGrayView1LeadingToContentViewLeading_IPadProLandscape          40.f
#define kCurrentWeatherTopToGrayView1Top_IPadProLandscape               50.f
#define kCurrentTemperatureLeadingToGrayView1Leading_IPadProLandscape   40.f
#define kPrecipitationLeadingToGrayView1Leading_IPadProLandscape        50.f
#define kWeatherIconTopToCurrentWeatherBottom_IPadProLandscape          70.f
#define kWeatherIconTrailingToGrayView1Trailing_IPadProLandscape        -40.f
#define kWeatherTypeTrailingToGrayView1Trailing_IPadProLandscape        -50.f
#define kGrayView1BottomToGrayView4Top_IPadProLandscape                 -40.f

#define kGrayView1TopToContentViewTop_IPadProPortrait                   40.f
#define kGrayView1LeadingToContentViewLeading_IPadProPortrait           40.f
#define kGrayView1TrailingToContentViewTrailing_IPadProPortrait         40.f
#define kGrayView1BottomToTemperatureTodayBottom_IPadProPortrait        30.f
#define kCurrentWeatherTopToGrayView1Top_IPadProPortrait                30.f
#define kCurrentTemperatureLeadingToGrayView1Leading_IPadProPortrait    95.f
#define kPrecipitationLeadingToGrayView1Leading_IPadProPortrait         100.f
#define kWeatherIconTopToCurrentWeatherBottom_IPadProPortrait           40.f
#define kWeatherIconTrailingToGrayView1Trailing_IPadProPortrait         -90.f
#define kWeatherTypeTopToWeatherIconTop_IPadProPortrait                 40.f
#define kWeatherTypeTrailingToGrayView1Trailing_IPadProPortrait         -100.f


// Gray view 2 Weather Forecast
#define kExtendedTextFontSize_IPadPro   25.f
#define kAlertButtonFontSize_IPadPro    20.f

#define kGrayView2LeadingToGrayView1Trailing_IPadProLandscape       40.f
#define kGrayView2TrailingToContentViewTrailing_IPadProLandscape    40.f
#define kExtendedTitleTopToGrayView2Top_IPadProLandscape            50.f
#define kExtendedTextTopToExtendedTitleBottom_IPadProLandscape      20.f
#define kExtendedTitleLeadingToGrayView2Leading_IPadProLandscape    50.f
#define kExtendedTitleTrailing2GrayView2Trailing_IPadProLandscape   -50.f
#define kAlertViewTrailingToGrayView2Trailing_IPadProLandscape      -50.f
#define kAlertViewBottomToGrayView2Bottom_IPadProLandscape          -40.f

#define kGrayView2TopToGrayView1Bottom_IPadProPortrait              40.f
#define kExtendedTitleTopToGrayView2Top_IPadProPortrait             30.f
#define kExtendedTextTopToExtendedTitleBottom_IPadProPortrait       30.f
#define kExtendedTitleLeadingToGrayView2Leading_IPadProPortrait     60.f
#define kExtendedTitleTrailing2GrayView2Trailing_IPadProPortrait    -60.f
#define kAlertViewTrailingToGrayView2Trailing_IPadProPortrait       -60.f
#define kAlertViewBottomToGrayView2Bottom_IPadProPortrait           -40.f

// auto layout parameters for Alert Button
#define kGrayView2BottomToExtendedTextBottomWithAlert_IPadProPortrait       65.f
#define kGrayView2BottomToExtendedTextBottomWithNoAlert_IPadProPortrait     50.f
#define kExtendedTextBottomToGrayView2BottomWithAlert_IPadProLandscape      -75.f
#define kExtendedTextBottomToGrayView2BottomWithNoAlert_IPadProLandscape    -50.f

// Gray view 3 Genetic Forecast
#define kGeneticForecastTextFontSize_IPadPro    25.f
#define kPoweredByFontSize_IPadPro              15.f

#define kGrayView3TopToGrayView2Bottom_IPadProLandscape             30.f
#define kGeneticTitleTopToGrayView3Top_IPadProLandscape             50.f
#define kGeneticTitleLeadingToGrayView3Leading_IPadProLandscape     50.f
#define kGeneticTitleTrailingToGrayView3Trailing_IPadProLandscape   -50.f
#define kLogoLeadingToGrayView3Leading_IPadProLandscape             40.f
#define kGeneticTextTopToGeneticTitleBottom_IPadProLandscape        20.f
#define kGeneticTextLeadingToLogoTrailing_IPadProLandscape          30.f
#define kGeneticTextBottomToPoweredTop_IPadProLandscape             -20.f
#define kPoweredTrailingToGrayView3Trailing_IPadProLandscape        -50.f
#define kPoweredBottomToGrayView3Bottom_IPadProLandscape            -40.f

#define kGrayView3TopToGrayView2Bottom_IPadProPortrait              40.f
#define kGrayView3BottomToPoweredBottom_IPadProPortrait             30.f
#define kGeneticTitleTopToGrayView3Top_IPadProPortrait              30.f
#define kGeneticTitleLeadingToGrayView3Leading_IPadProPortrait      60.f
#define kGeneticTitleTrailingToGrayView3Trailing_IPadProPortrait    -60.f
#define kLogoLeadingToGrayView3Leading_IPadProPortrait              50.f
#define kGeneticTextTopToGeneticTitleBottom_IPadProPortrait         20.f
#define kGeneticTextLeadingToLogoTrailing_IPadProPortrait           30.f
#define kPoweredTopToGeneticTextBottom_IPadProPortrait              20.f
#define kPoweredTrailingToGrayView3Trailing_IPadProPortrait         -60.f

// Gray view 4 Forecast 7/10 days
#define kForecastDayName_IPadPro        20.f
#define kForecastDayTemperature_IPadPro 20.f

#define kGrayView4BottomToScrollViewBottom_IPadProLandscape     40.f
#define kForecast1TopToGrayView4Top_IPadProLandscape            40.f
#define kForecast1LeadingToGrayView4Leading_IPadProLandscape    30.f
#define kGrayView4BottomToForecast1Bottom_IPadProLandscape      40.f

#define kForecast1WidthMultiplier_IPadProPortrait  0.133f
#define kForecast1WidthMultiplier_IPadProLandscape 0.093f

#define kGrayView4TopToGrayView3Bottom_IPadProPortrait      40.f
#define kForecast1TopToGrayView4Top_IPadProPortrait         30.f
#define kForecast1LeadingToGrayView4Leading_IPadProPortrait 25.f
#define kGrayView4BottomToForecast1Bottom_IPadProPortrait   30.f





// ============================================================================
// iPhone
// ============================================================================
#pragma mark -
#pragma mark iPhone

// common font sizes
#define kGrayViewTitleFontSize_IPhone   18.f

// Gray view 1: Current Temperature
#define kWeatherIconWidthHeight_IPhone                  140.f
#define kCurrentTemperatureFontSize_IPhone              110.f
#define kCurrentTemperatureFontSizeLess_IPhone          105.f
#define kCurrentTemperatureUnitFontSize_IPhone          25.f
#define kCurrentTemperatureUnitBaselineOffset_IPhone    60
#define kTodaysTemperatureAndWeatherTypeFontSize_IPhone 16.f
#define kWindHumidityAndPrecipitationFontSize_IPhone    13.f

#define kGrayView1TopToContentViewTop_IPhonePortrait                0.f
#define kGrayView1LeadingToContentViewLeading_IPhonePortrait        0.f
#define kGrayView1TrailingToContentViewTrailing_IPhonePortrait      0.f
#define kGrayView1BottomToTemperatureTodayBottom_IPhonePortrait     15.f
#define kCurrentWeatherTopToGrayView1Top_IPhonePortrait             20.f
#define kCurrentTemperatureLeadingToGrayView1Leading_IPhonePortrait 15.f
#define kWeatherIconTopToCurrentWeatherBottom_IPhonePortrait        -25.f
#define kWeatherIconTrailingToGrayView1Trailing_IPhonePortrait      -10.f
#define kWeatherTypeTopToWeatherIconTop_IPhonePortrait              0.f
#define kWeatherTypeTrailingToGrayView1Trailing_IPhonePortrait      -20.f
#define kTemperatureTodayTopToWeatherTypeBottom_IPhonePortrait      0.f
#define kPrecipitationLeadingToGrayView1Leading_IPhonePortrait      20.f
#define kHumidityBottomToPrecipitationTop_IPhonePortrait            0.f
#define kWindBottomToHumidityTop_IPhonePortrait                     0.f

#define kGrayView1TopToContentViewTop_IPhoneLandscape               0.f
#define kGrayView1LeadingToContentViewLeading_IPhoneLandscape       20.f
#define kGrayView1LeadingToContentViewLeading_IPhone6Landscape      40.f
#define kGrayView1TrailingToContentViewTrailing_IPhoneLandscape     20.f
#define kGrayView1TrailingToContentViewTrailing_IPhone6Landscape    40.f
#define kGrayView1BottomToTemperatureTodayBottom_IPhoneLandscape    15.f
#define kCurrentWeatherTopToGrayView1Top_IPhoneLandscape            20.f

#define kCurrentTemperatureLeadingToGrayView1Leading_IPhoneLandscape 40.f
#define kCurrentTemperatureLeadingToGrayView1Leading_IPhone6Landscape 40.f
#define kPrecipitationLeadingToGrayView1Leading_IPhoneLandscape     40.f
#define kPrecipitationLeadingToGrayView1Leading_IPhone6Landscape    40.f
#define kWeatherIconTrailingToGrayView1Trailing_IPhoneLandscape     -40.f
#define kWeatherIconTrailingToGrayView1Trailing_IPhone6Landscape    -40.f
#define kWeatherTypeTrailingToGrayView1Trailing_IPhoneLandscape     -40.f
#define kWeatherTypeTrailingToGrayView1Trailing_IPhone6Landscape    -40.f

#define kWeatherIconTopToCurrentWeatherBottom_IPhoneLandscape       -25.f
#define kWeatherTypeTopToWeatherIconTop_IPhoneLandscape             5.f
#define kTemperatureTodayTopToWeatherTypeBottom_IPhoneLandscape     0.f
#define kHumidityBottomToPrecipitationTop_IPhoneLandscape           -3.f
#define kWindBottomToHumidityTop_IPhoneLandscape                    -3.f

// Gray view 2 Weather Forecast
#define kExtendedTextFontSize_IPhone    16.f
#define kAlertButtonFontSize_IPhone     15.f

#define kGrayView2TopToGrayView1Bottom_IPhonePortrait           15.f
#define kExtendedTitleTopToGrayView2Top_IPhonePortrait          15.f
#define kExtendedTitleLeadingToGrayView2Leading_IPhonePortrait  20.f
#define kExtendedTitleTrailing2GrayView2Trailing_IPhonePortrait -20.f
#define kExtendedTextTopToExtendedTitleBottom_IPhonePortrait    8.f
#define kAlertViewTrailingToGrayView2Trailing_IPhonePortrait    -20.f
#define kAlertViewBottomToGrayView2Bottom_IPhonePortrait        -20.f

#define kGrayView2TopToGrayView1Bottom_IPhoneLandscape          15.f
#define kExtendedTitleTopToGrayView2Top_IPhoneLandscape         15.f
#define kExtendedTitleLeadingToGrayView2Leading_IPhoneLandscape 40.f
#define kExtendedTitleTrailing2GrayView2Trailing_IPhoneLandscape -40.f
#define kExtendedTextTopToExtendedTitleBottom_IPhoneLandscape   8.f
#define kAlertViewTrailingToGrayView2Trailing_IPhoneLandscape   -40.f
#define kAlertViewBottomToGrayView2Bottom_IPhoneLandscape       -20.f

// auto layout parameters for Alert Button
#define kGrayView2BottomToExtendedTextBottomWithAlert_IPhonePortrait    50.f
#define kGrayView2BottomToExtendedTextBottomWithNoAlert_IPhonePortrait  15.f
#define kGrayView2BottomToExtendedTextBottomWithAlert_IPhoneLandscape   50.f
#define kGrayView2BottomToExtendedTextBottomWithNoAlert_IPhoneLandscape 20.f

// Gray view 3 Genetic Forecast
#define kGeneticForecastTextFontSize_IPhone 16.f
#define kPoweredByFontSize_IPhone           9.f

#define kGrayView3TopToGrayView2Bottom_IPhonePortrait           15.f
#define kGrayView3BottomToPoweredBottom_IPhonePortrait          10.f
#define kGeneticTitleTopToGrayView3Top_IPhonePortrait           15.f
#define kGeneticTitleLeadingToGrayView3Leading_IPhonePortrait   20.f
#define kGeneticTitleTrailingToGrayView3Trailing_IPhonePortrait -20.f
#define kLogoLeadingToGrayView3Leading_IPhonePortrait           15.f
#define kLogoIconWidth_IPhonePortrait                           45.f
#define kGeneticTextTopToGeneticTitleBottom_IPhonePortrait      8.f
#define kGeneticTextLeadingToLogoTrailing_IPhonePortrait        15.f
#define kPoweredTopToGeneticTextBottom_IPhonePortrait           5.f
#define kPoweredTrailingToGrayView3Trailing_IPhonePortrait      -20.f

#define kGrayView3TopToGrayView2Bottom_IPhoneLandscape          15.f
#define kGrayView3BottomToPoweredBottom_IPhoneLandscape         15.f
#define kGeneticTitleTopToGrayView3Top_IPhoneLandscape          15.f
#define kGeneticTitleLeadingToGrayView3Leading_IPhoneLandscape  40.f
#define kGeneticTitleTrailingToGrayView3Trailing_IPhoneLandscape -40.f
#define kLogoLeadingToGrayView3Leading_IPhoneLandscape          35.f
#define kLogoIconWidth_IPhoneLandscape                          45.f
#define kGeneticTextTopToGeneticTitleBottom_IPhoneLandscape     8.f
#define kGeneticTextLeadingToLogoTrailing_IPhoneLandscape       15.f
#define kPoweredTopToGeneticTextBottom_IPhoneLandscape          5.f
#define kPoweredTrailingToGrayView3Trailing_IPhoneLandscape     -40.f

// Gray view 4 Forecast 4/7 days
#define kForecastDayName_IPhone             13.f
#define kForecastDayTemperature_IPhone      13.f
#define kForecastDayTemperatureSmall_IPhone 12.f

#define kGrayView4TopToGrayView3Bottom_IPhonePortrait       15.f
#define kGrayView4BottomToForecast1Bottom_IPhonePortrait    15.f
#define kForecast1TopToGrayView4Top_IPhonePortrait          15.f
#define kForecast1LeadingToGrayView4Leading_IPhone4Portrait 2.f
#define kForecast1LeadingToGrayView4Leading_IPhone5Portrait 2.f
#define kForecast1LeadingToGrayView4Leading_IPhone6Portrait 2.f
#define kForecast1WidthMultiplier_IPhone4Portrait           0.24f
#define kForecast1WidthMultiplier_IPhone5Portrait           0.24f
#define kForecast1WidthMultiplier_IPhone6Portrait           0.24f

#define kGrayView4TopToGrayView3Bottom_IPhoneLandscape      15.f
#define kGrayView4BottomToForecast1Bottom_IPhoneLandscape   10.f
#define kForecast1TopToGrayView4Top_IPhoneLandscape         10.f
#define kForecast1LeadingToGrayView4Leading_IPhone4Landscape 16.f
#define kForecast1LeadingToGrayView4Leading_IPhone5Landscape 44.f
#define kForecast1LeadingToGrayView4Leading_IPhone6Landscape 44.f
#define kForecast1WidthMultiplier_IPhone4Landscape          0.15f
#define kForecast1WidthMultiplier_IPhone5Landscape          0.14f
#define kForecast1WidthMultiplier_IPhone6Landscape          0.14f




// ============================================================================
// iPhone 6/7 Plus
// ============================================================================
#pragma mark -
#pragma mark iPhone Plus

// common font sizes
#define kLocationNameFontSize_IPhonePlus    17
#define kLocationDateFontSize_IPhonePlus    13
#define kGrayViewTitleFontSize_IPhonePlus   16.f

// Gray view 1: Current Temperature
#define kWeatherIconWidthHeight_IPhonePlus                  140.f
#define kCurrentTemperatureFontSize_IPhonePlus              110.f
#define kCurrentTemperatureUnitFontSize_IPhonePlus          20.f
#define kCurrentTemperatureUnitBaselineOffset_IPhonePlus    70
#define kTodaysTemperatureAndWeatherTypeFontSize_IPhonePlus 14.f
#define kWindHumidityAndPrecipitationFontSize_IPhonePlus    12.f

#define kGrayView1TopToContentViewTop_IPhonePlusPortrait                0.f
#define kGrayView1LeadingToContentViewLeading_IPhonePlusPortrait        20.f
#define kGrayView1TrailingToContentViewTrailing_IPhonePlusPortrait      20.f
#define kGrayView1BottomToTemperatureTodayBottom_IPhonePlusPortrait     20.f
#define kCurrentWeatherTopToGrayView1Top_IPhonePlusPortrait             15.f
#define kCurrentTemperatureLeadingToGrayView1Leading_IPhonePlusPortrait 20.f
#define kWeatherIconTopToCurrentWeatherBottom_IPhonePlusPortrait        0.f
#define kWeatherIconTrailingToGrayView1Trailing_IPhonePlusPortrait      -15.f
#define kWeatherTypeTopToWeatherIconTop_IPhonePlusPortrait              10.f
#define kWeatherTypeTrailingToGrayView1Trailing_IPhonePlusPortrait      -20.f
#define kTemperatureTodayTopToWeatherTypeBottom_IPhonePlusPortrait      0.f
#define kPrecipitationLeadingToGrayView1Leading_IPhonePlusPortrait      20.f
#define kHumidityBottomToPrecipitationTop_IPhonePlusPortrait            0.f
#define kWindBottomToHumidityTop_IPhonePlusPortrait                     0.f

#define kGrayView1TopToContentViewTop_IPhonePlusLandscape               0.f
#define kGrayView1LeadingToContentViewLeading_IPhonePlusLandscape       20.f
#define kCurrentWeatherTopToGrayView1Top_IPhonePlusLandscape            5.f
#define kCurrentTemperatureLeadingToGrayView1Leading_IPhonePlusLandscape 15.f
#define kPrecipitationLeadingToGrayView1Leading_IPhonePlusLandscape     20.f
#define kWeatherIconTopToCurrentWeatherBottom_IPhonePlusLandscape       0.f
#define kWeatherIconTrailingToGrayView1Trailing_IPhonePlusLandscape     -10.f
#define kWeatherTypeTrailingToGrayView1Trailing_IPhonePlusLandscape     -20.f
#define kGrayView1BottomToGrayView4Top_IPhonePlusLandscape              -15.f


// Gray view 2 Weather Forecast
#define kExtendedTextFontSize_IPhonePlus    14.f
#define kAlertButtonFontSize_IPhonePlus     12.f

#define kGrayView2TopToGrayView1Bottom_IPhonePlusPortrait           20.f
#define kExtendedTitleTopToGrayView2Top_IPhonePlusPortrait          15.f
#define kExtendedTitleLeadingToGrayView2Leading_IPhonePlusPortrait  20.f
#define kExtendedTitleTrailing2GrayView2Trailing_IPhonePlusPortrait -20.f
#define kExtendedTextTopToExtendedTitleBottom_IPhonePlusPortrait    10.f
#define kAlertViewTrailingToGrayView2Trailing_IPhonePlusPortrait    -20.f
#define kAlertViewBottomToGrayView2Bottom_IPhonePlusPortrait        -20.f

#define kGrayView2LeadingToGrayView1Trailing_IPhonePlusLandscape    15.f
#define kGrayView2TrailingToContentViewTrailing_IPhonePlusLandscape 20.f
#define kExtendedTitleTopToGrayView2Top_IPhonePlusLandscape         5.f
#define kExtendedTextTopToExtendedTitleBottom_IPhonePlusLandscape   8.f
#define kExtendedTitleLeadingToGrayView2Leading_IPhonePlusLandscape 15.f
#define kExtendedTitleTrailing2GrayView2Trailing_IPhonePlusLandscape -15.f
#define kAlertViewTrailingToGrayView2Trailing_IPhonePlusLandscape   -20.f
#define kAlertViewBottomToGrayView2Bottom_IPhonePlusLandscape       -10.f

// auto layout parameters for Alert Button
#define kGrayView2BottomToExtendedTextBottomWithAlert_IPhonePlusPortrait    45.f
#define kGrayView2BottomToExtendedTextBottomWithNoAlert_IPhonePlusPortrait  20.f
#define kExtendedTextBottomToGrayView2BottomWithAlert_IPhonePlusLandscape   -25.f
#define kExtendedTextBottomToGrayView2BottomWithNoAlert_IPhonePlusLandscape -10.f

// Gray view 3 Genetic Forecast
#define kGeneticForecastTextFontSize_IPhonePlus 14.f
#define kPoweredByFontSize_IPhonePlus           9.f

#define kGrayView3TopToGrayView2Bottom_IPhonePlusPortrait           20.f
#define kGrayView3BottomToPoweredBottom_IPhonePlusPortrait          10.f
#define kGeneticTitleTopToGrayView3Top_IPhonePlusPortrait           15.f
#define kGeneticTitleLeadingToGrayView3Leading_IPhonePlusPortrait   20.f
#define kGeneticTitleTrailingToGrayView3Trailing_IPhonePlusPortrait -20.f
#define kLogoLeadingToGrayView3Leading_IPhonePlusPortrait           15.f
#define kLogoIconWidth_IPhonePlusPortrait                           45.f
#define kGeneticTextTopToGeneticTitleBottom_IPhonePlusPortrait      8.f
#define kGeneticTextLeadingToLogoTrailing_IPhonePlusPortrait        15.f
#define kPoweredTopToGeneticTextBottom_IPhonePlusPortrait           10.f
#define kPoweredTrailingToGrayView3Trailing_IPhonePlusPortrait      -20.f

#define kGrayView3TopToGrayView2Bottom_IPhonePlusLandscape          10.f
#define kGeneticTitleTopToGrayView3Top_IPhonePlusLandscape          5.f
#define kGeneticTitleLeadingToGrayView3Leading_IPhonePlusLandscape  20.f
#define kGeneticTitleTrailingToGrayView3Trailing_IPhonePlusLandscape -20.f
#define kLogoLeadingToGrayView3Leading_IPhonePlusLandscape          15.f
#define kGeneticTextTopToGeneticTitleBottom_IPhonePlusLandscape     5.f
#define kGeneticTextLeadingToLogoTrailing_IPhonePlusLandscape       15.f
#define kGeneticTextBottomToPoweredTop_IPhonePlusLandscape          -5.f
#define kPoweredTrailingToGrayView3Trailing_IPhonePlusLandscape     -20.f
#define kPoweredBottomToGrayView3Bottom_IPhonePlusLandscape         -10.f

// Gray view 4 Forecast 7/10 days
#define kForecastDayName_IPhonePlus             12.f
#define kForecastDayTemperature_IPhonePlus      12.f
#define kForecastDayTemperatureSmall_IPhonePlus 11.f

#define kGrayView4TopToGrayView3Bottom_IPhonePlusPortrait       20.f
#define kGrayView4BottomToForecast1Bottom_IPhonePlusPortrait    15.f
#define kForecast1TopToGrayView4Top_IPhonePlusPortrait          15.f
#define kForecast1LeadingToGrayView4Leading_IPhonePlusPortrait  16.f
#define kForecast1WidthMultiplier_IPhonePlusPortrait            0.22f

#define kGrayView4BottomToScrollViewBottom_IPhonePlusLandscape  0.f
#define kGrayView4BottomToForecast1Bottom_IPhonePlusLandscape   10.f
#define kForecast1TopToGrayView4Top_IPhonePlusLandscape         10.f
#define kForecast1LeadingToGrayView4Leading_IPhonePlusLandscape 50.f
#define kForecast1WidthMultiplier_IPhonePlusLandscape           0.09f





@interface ForecastLayout : NSObject

@end
