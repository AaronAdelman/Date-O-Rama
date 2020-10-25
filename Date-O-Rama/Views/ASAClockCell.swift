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
                #if os(watchOS)
                Text(verbatim:  processedRow.calendarString).font(.subheadline).multilineTextAlignment(.leading)
                #else
                HStack {
                    ASACalendarSymbol()
                    Text(verbatim:  processedRow.calendarString).font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
                }.frame(height: ROW_HEIGHT)
                #endif
            }

            HStack {
                Spacer().frame(width: self.INSET)

                #if os(watchOS)
                VStack {
                    if !shouldShowPlaceName {
                        if processedRow.usesDeviceLocation {
                            ASASmallLocationSymbol()
                        }
                    }
                }
                #endif
                
                VStack(alignment: .leading) {
                    if processedRow.canSplitTimeFromDate {
                        if shouldShowFormattedDate {
//                            #if os(watchOS)
//                            Text(verbatim:  processedRow.dateString)
//                                .font(Font.subheadline.monospacedDigit())
//                                .multilineTextAlignment(.leading).lineLimit(2)
//                                .fixedSize(horizontal: false, vertical: true)
//                            #else
                            Text(verbatim:  processedRow.dateString)
                                .font(Font.headline.monospacedDigit())
                                .multilineTextAlignment(.leading).lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
//                            #endif
                        }
                        if shouldShowTime {
//                            #if os(watchOS)
//                            Text(verbatim:  processedRow.timeString ?? "")
//                                .font(Font.subheadline.monospacedDigit())
//                                .multilineTextAlignment(.leading).lineLimit(2)  .fixedSize(horizontal: false, vertical: true)
//                            #else
                            Text(verbatim:  processedRow.timeString ?? "")
                                .font(Font.headline.monospacedDigit())
                                .multilineTextAlignment(.leading).lineLimit(2)  .fixedSize(horizontal: false, vertical: true)
//                            #endif
                        }
                    } else if shouldShowFormattedDate {
//                        #if os(watchOS)
//                        Text(verbatim:  processedRow.dateString)
//                            .font(Font.subheadline.monospacedDigit())
//                            .multilineTextAlignment(.leading).lineLimit(2)  .fixedSize(horizontal: false, vertical: true)
//                        #else
                        Text(verbatim:  processedRow.dateString)
                            .font(Font.headline.monospacedDigit())
                            .multilineTextAlignment(.leading).lineLimit(2)  .fixedSize(horizontal: false, vertical: true)
//                        #endif

                    }
                } // VStack
            } // HStack

            if shouldShowPlaceName {
                HStack {
                    VStack(alignment: .leading) {
                        if processedRow.supportsTimeZones || processedRow.supportsLocations {
//                            #if os(watchOS)
//                            HStack {
//                                if processedRow.usesDeviceLocation {
//                                    ASASmallLocationSymbol()
//                                }
//                                Text(processedRow.locationString).font(.subheadline)
//                            }
//                            #else
                            HStack {
                                Spacer().frame(width: self.INSET)
                                if processedRow.usesDeviceLocation {
                                    ASASmallLocationSymbol()
                                }
                                Text(verbatim:  processedRow.emojiString)

                                Text(processedRow.locationString).font(.subheadline)
                            } // HStack
//                            #endif
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

struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic(), now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: 20.0, shouldShowTime: true)
    }
} // struct ASAClockCell_Previews
