//
//  ForecastLayout.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


// iPad regular font sizes
#define kCurrentTemperatureFontSize             180.f
#define kCurrentTemperatureUnitFontSize         35.f
#define kCurrentTemperatureUnitBaselineOffset   105
#define kTodaysTemperatureFontSize              22.f



// ============================================================================
// iPad Pro 12.9"
// ============================================================================

// common font sizes
#define kGrayViewTitleFontSize_IPadPro          30.f

// Gray view 1: Current Temperature
#define kWeatherIconWidthHeight_IPad                        190.f
#define kWeatherIconWidthHeight_IPadPro                     240.f
#define kCurrentTemperatureFontSize_IPadPro                 250.f
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
#define kGrayView2BottomToExtendedTextBottomWithAlert_IPadPortrait      55.f
#define kGrayView2BottomToExtendedTextBottomWithNoAlert_IPadPortrait    40.f
#define kExtendedTextBottomToGrayView2BottomWithAlert_IPadLandscape     -65.f
#define kExtendedTextBottomToGrayView2BottomWithNoAlert_IPadLandscape   -30.f

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
#define kForecastDayName                14.f
#define kForecastDayTemperature         14.f
#define kForecastDayName_IPadPro        20.f
#define kForecastDayTemperature_IPadPro 20.f

#define kGrayView4BottomToScrollViewBottom_IPadProLandscape     40.f
#define kForecast1TopToGrayView4Top_IPadProLandscape            40.f
#define kForecast1LeadingToGrayView4Leading_IPadProLandscape    30.f
#define kGrayView4BottomToForecast1Bottom_IPadProLandscape      40.f

#define kGrayView4TopToGrayView3Bottom_IPadProPortrait      40.f
#define kForecast1TopToGrayView4Top_IPadProPortrait         30.f
#define kForecast1LeadingToGrayView4Leading_IPadProPortrait 25.f
#define kGrayView4BottomToForecast1Bottom_IPadProPortrait   30.f


@interface ForecastLayout : NSObject

@end
