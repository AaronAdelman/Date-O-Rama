//
//  ASAClockCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAClockCell: View {
    var processedRow:  ASAProcessedRow
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool

    var INSET:  CGFloat
    var shouldShowTime:  Bool

    let ROW_HEIGHT = 30.0 as CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            if shouldShowCalendar {
                HStack {
                    #if os(watchOS)
                    #else
                    ASACalendarSymbol()
                    #endif
                    ASAClockCellText(string:  processedRow.calendarString, font:  .subheadline)
                }
            }

            HStack {
                Spacer().frame(width: self.INSET)

                #if os(watchOS)
                if !shouldShowPlaceName {
                    if processedRow.usesDeviceLocation {
                        ASASmallLocationSymbol()
                    }
                }
                #endif
                
                VStack(alignment: .leading) {
                    if processedRow.canSplitTimeFromDate {
                        if shouldShowFormattedDate {
                            ASAClockCellText(string:  processedRow.dateString, font:  Font.headline.monospacedDigit())
                        }
                        if shouldShowTime {
                            ASAClockCellText(string:  processedRow.timeString ?? "", font:  Font.subheadline.monospacedDigit())
                        }
                    } else if shouldShowFormattedDate {
                        ASAClockCellText(string:  processedRow.dateString, font:  Font.headline.monospacedDigit())
                    }
                } // VStack
            } // HStack

            if shouldShowPlaceName {
                HStack {
                    VStack(alignment: .leading) {
                        if processedRow.supportsTimeZones || processedRow.supportsLocations {
                            HStack {
                                Spacer().frame(width: self.INSET)
                                if processedRow.usesDeviceLocation {
                                    ASASmallLocationSymbol()
                                }
                                Text(verbatim:  processedRow.emojiString)

                                Text(processedRow.locationString).font(.subheadline)
                            } // HStack
                        }
                    }
                }
            } else if processedRow.usesDeviceLocation {
                #if os(watchOS)
                #else
                HStack {
                    Spacer().frame(width: self.INSET)
                    ASASmallLocationSymbol()
                } // HStack
                #endif
            }
        } // VStack
    } // var body
} // struct ASAClockCell


struct ASAClockCellText:  View {
    var string:  String
    var font:  Font

    var body: some View {
        #if os(watchOS)
        Text(verbatim:  string)
            .font(font)
            .minimumScaleFactor(0.5).lineLimit(1)
            .fixedSize(horizontal: false, vertical: true)
        #else
        Text(verbatim:  string)
            .font(font)
            .multilineTextAlignment(.leading).lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
        #endif
    } // var body
} // struct ASAClockCellText


struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic(), now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: 20.0, shouldShowTime: true)
    }
} // struct ASAClockCell_Previews
