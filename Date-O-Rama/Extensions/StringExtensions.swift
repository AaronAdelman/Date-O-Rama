//
//  StringExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2018-08-05.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import Foundation
import SwiftAA

// MARK:  - ISO 3166 country/region codes.  Mostly ISO 3166-1 with some MARC codes for locations off Earth.

extension String {
    // Based on https://stackoverflow.com/questions/30402435/swift-turn-a-country-code-into-a-emoji-flag-via-unicode
    // Converts a country code into a Unicode emoji flag
    var flag:  String {
        let FAILURE_FLAG = "📍"
        let EARTH_FLAG   = "🌐"
        
        if self == "" {
            return FAILURE_FLAG
        }
        
        if self.count == 1 {
            if self == REGION_CODE_Earth {
                return EARTH_FLAG
            } else {
                return FAILURE_FLAG
            }
        }
        
        if self.count == 3 {
            // We are probably dealing with a UN M49 code
            switch self {
            case "001": // Earth in general
                return EARTH_FLAG
                
            case "002", "015", "202", "014", "017", "018", "011": // Africa
                return "🌍"
                
            case "019", "419", "029", "013", "005", "003", "021": // Americas
                return "🌎"
                
            case "142", "143", "030", "035", "034", "145": // Asia
                return "🌏"
                
            case "150", "151", "154", "039", "155": // Europe
                return "🇪🇺"
                
            case "009", "053", "054", "057", "061": // Oceania
                return "🌏"
                
            case REGION_CODE_Sun:
                return "☉"
                
            case REGION_CODE_Mercury:
                return "☿"
                
            case REGION_CODE_Venus:
                return "♀"
                
            case REGION_CODE_Moon:
                return "☽"
                
            case REGION_CODE_Mars:
                return "♂"
                
            case REGION_CODE_Jupiter:
                return "♃"
                
            case REGION_CODE_Saturn:
                return "♄"
                
            case REGION_CODE_Uranus:
                return "⛢"
                
            case REGION_CODE_Neptune:
                return "♆"
                
            case REGION_CODE_Pluto:
                return "♇"
                
            default:
                return FAILURE_FLAG
            } // switch self
        }
        
        return self
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    } // var flag

// TODO:  As of this writing, not all calendars in official use are implemented yet.

    var defaultCalendarCodes: Array<ASACalendarCode> {
        switch self {
        case REGION_CODE_Afghanistan, REGION_CODE_Iran:
            return [.gregorian, .persian, .islamicSolarTime]
            
        case REGION_CODE_Ethiopia:
            return [.gregorian, .ethiopicAmeteMihret]
            
        case REGION_CODE_Japan:
            return [.gregorian, .japanese]
            
        case REGION_CODE_Taiwan:
            return [.gregorian, .republicOfChina, .chinese]
            
        case REGION_CODE_Thailand:
            return [.gregorian, .buddhist, .islamicSolarTime]
            
        case REGION_CODE_Algeria, REGION_CODE_Iraq, REGION_CODE_Mauritania, REGION_CODE_Morocco, REGION_CODE_Oman, REGION_CODE_Pakistan, REGION_CODE_Somalia, REGION_CODE_Tunisia, REGION_CODE_United_Arab_Emirates, REGION_CODE_Yemen, REGION_CODE_Kuwait, REGION_CODE_Qatar, REGION_CODE_Palestine, REGION_CODE_Burundi, REGION_CODE_Burkina_Faso, REGION_CODE_Cameroon, REGION_CODE_Central_African_Republic, REGION_CODE_Chad, REGION_CODE_Comoros, REGION_CODE_Cote_dIvoire, REGION_CODE_Djibouti, REGION_CODE_Gabon, REGION_CODE_Gambia, REGION_CODE_Ghana, REGION_CODE_Guinea, REGION_CODE_Guinea_Bissau, REGION_CODE_Guyana, REGION_CODE_Azerbaijan, REGION_CODE_Bangladesh, REGION_CODE_Bahrain, REGION_CODE_Kenya, REGION_CODE_Madagascar, REGION_CODE_Malawi, REGION_CODE_Mali, REGION_CODE_Myanmar, REGION_CODE_Nepal, REGION_CODE_Niger, REGION_CODE_Nigeria, REGION_CODE_Rwanda, REGION_CODE_Samoa, REGION_CODE_Senegal, REGION_CODE_Sierra_Leone, REGION_CODE_South_Sudan, REGION_CODE_Spain, REGION_CODE_Sri_Lanka, REGION_CODE_Tajikistan, REGION_CODE_Tanzania, REGION_CODE_Togo, REGION_CODE_Trinidad_and_Tobago, REGION_CODE_Turkey, REGION_CODE_Turkmenistan, REGION_CODE_Uganda, REGION_CODE_Uzbekistan:
            return [.gregorian, .islamicSolarTime]
            
        case REGION_CODE_Libya, REGION_CODE_Lebanon, REGION_CODE_Eritrea, REGION_CODE_Bosnia_and_Herzegovina, REGION_CODE_Jordan, REGION_CODE_Kazakhstan, REGION_CODE_Kosovo, REGION_CODE_North_Macedonia:
            return [.gregorian, .islamicSolarTime, .julian]

        case REGION_CODE_Egypt, REGION_CODE_Sudan:
            return [.gregorian, .islamicSolarTime, .coptic]
            
        case REGION_CODE_India:
            return [.gregorian, .indian]
            
        case REGION_CODE_Israel:
            return [.gregorian, .hebrewGRA]
            
        case REGION_CODE_Saudi_Arabia:
            return [.gregorian, .islamicUmmAlQuraSolarTime]
            
        case REGION_CODE_Albania, REGION_CODE_Romania, REGION_CODE_Bulgaria, REGION_CODE_Georgia, REGION_CODE_Greece, REGION_CODE_Ukraine, REGION_CODE_Cyprus, REGION_CODE_Kyrgyzstan, REGION_CODE_Moldova, REGION_CODE_Montenegro, REGION_CODE_Serbia:
            return [.gregorian, .julian]
            
        case REGION_CODE_China, REGION_CODE_Christmas_Island, REGION_CODE_Hong_Kong, REGION_CODE_South_Korea, REGION_CODE_Macao, REGION_CODE_Singapore, REGION_CODE_Vietnam:
            return [.gregorian, .chinese]
            
        case REGION_CODE_Brunei_Darussalam, REGION_CODE_Indonesia, REGION_CODE_Malaysia, REGION_CODE_Timor_Leste, REGION_CODE_Mauritius, REGION_CODE_Philippines, REGION_CODE_Suriname:
            return [.gregorian, .chinese, .islamicSolarTime]
            
        case REGION_CODE_Ethiopia:
            return [.gregorian, .julian, .islamicSolarTime, .ethiopicAmeteMihret]

        default:
            return [.gregorian]
        } // switch self
    } // var defaultCalendarCodes
    
    var superregionCode: String? {
        switch self {
        case REGION_CODE_Hong_Kong, REGION_CODE_Macao: // Taiwan is not part of Mainland China, no matter how much the illegal government of the rebel mainland provinces wants us to believe it is
            return REGION_CODE_China
            
        case REGION_CODE_Aland_Islands:
            return REGION_CODE_Finland
            
        case REGION_CODE_Saint_Barthelemy, REGION_CODE_French_Guiana, REGION_CODE_Guadeloupe, REGION_CODE_Saint_Martin, REGION_CODE_Martinique, REGION_CODE_New_Caledonia, REGION_CODE_French_Polynesia, REGION_CODE_Saint_Pierre_and_Miquelon, REGION_CODE_Reunion, REGION_CODE_French_Southern_Territories, REGION_CODE_Wallis_and_Futuna, REGION_CODE_Mayotte:
            return REGION_CODE_France
            
        case REGION_CODE_Aruba, REGION_CODE_Bonaire_Sint_Eustatius_and_Saba, REGION_CODE_Curacao, REGION_CODE_Sint_Maarten:
            return REGION_CODE_Netherlands
            
        case REGION_CODE_Svalbard_and_Jan_Mayen, REGION_CODE_Bouvet_Island:
            return REGION_CODE_Norway
            
        case REGION_CODE_American_Samoa, REGION_CODE_Guam, REGION_CODE_Northern_Mariana_Islands, REGION_CODE_Puerto_Rico, REGION_CODE_United_States_Minor_Outlying_Islands, REGION_CODE_United_States_Virgin_Islands:
            return REGION_CODE_United_States
            
        case REGION_CODE_Cook_Islands, REGION_CODE_Niue, REGION_CODE_Tokelau:
            return REGION_CODE_New_Zealand
            
        case REGION_CODE_Anguilla, REGION_CODE_Bermuda, REGION_CODE_British_Indian_Ocean_Territory, REGION_CODE_Cayman_Islands, REGION_CODE_Gibraltar, REGION_CODE_Guernsey, REGION_CODE_Norfolk_Island, REGION_CODE_British_Virgin_Islands, REGION_CODE_Sark:
            return REGION_CODE_United_Kingdom
            
        case REGION_CODE_Christmas_Island, REGION_CODE_Cocos_Islands, REGION_CODE_Falkland_Islands, REGION_CODE_Heard_Island_and_McDonald_Islands, REGION_CODE_Isle_of_Man, REGION_CODE_Jersey, REGION_CODE_Montserrat, REGION_CODE_Pitcairn, REGION_CODE_Saint_Helena_Ascension_and_Tristan_da_Cunha, REGION_CODE_South_Georgia_and_the_South_Sandwich_Islands, REGION_CODE_Turks_and_Caicos_Islands:
            return REGION_CODE_Australia
            
        case REGION_CODE_Faroe_Islands, REGION_CODE_Greenland:
            return REGION_CODE_Denmark
            
        case REGION_CODE_Western_Sahara:
            return REGION_CODE_Morocco
            
        case REGION_CODE_Austria, REGION_CODE_Belgium, REGION_CODE_Bulgaria, REGION_CODE_Croatia, REGION_CODE_Cyprus, REGION_CODE_Czechia, REGION_CODE_Denmark, REGION_CODE_Estonia, REGION_CODE_Finland, REGION_CODE_France, REGION_CODE_Germany, REGION_CODE_Greece, REGION_CODE_Hungary, REGION_CODE_Ireland, REGION_CODE_Italy, REGION_CODE_Latvia, REGION_CODE_Lithuania, REGION_CODE_Luxembourg, REGION_CODE_Malta, REGION_CODE_Netherlands, REGION_CODE_Poland, REGION_CODE_Portugal, REGION_CODE_Romania, REGION_CODE_Slovakia, REGION_CODE_Slovenia, REGION_CODE_Spain, REGION_CODE_Sweden:
            return REGION_CODE_European_Union
            
        case REGION_CODE_Algeria,
            REGION_CODE_Angola,
            REGION_CODE_Benin,
            REGION_CODE_Botswana,
            REGION_CODE_British_Indian_Ocean_Territory,
            REGION_CODE_Burkina_Faso,
            REGION_CODE_Burundi,
            REGION_CODE_Cameroon,
            REGION_CODE_Cabo_Verde,
            REGION_CODE_Central_African_Republic,
            REGION_CODE_Chad,
            REGION_CODE_Comoros,
            REGION_CODE_Democratic_Republic_of_the_Congo,
            REGION_CODE_Djibouti,
            REGION_CODE_Egypt,
            REGION_CODE_Equatorial_Guinea,
            REGION_CODE_Eritrea,
            REGION_CODE_Eswatini,
            REGION_CODE_Ethiopia,
            REGION_CODE_Gabon,
            REGION_CODE_Gambia,
            REGION_CODE_Ghana,
            REGION_CODE_Guinea,
            REGION_CODE_Guinea_Bissau,
            REGION_CODE_Cote_dIvoire,
            REGION_CODE_Kenya,
            REGION_CODE_Lesotho,
            REGION_CODE_Liberia,
            REGION_CODE_Libya,
            REGION_CODE_Madagascar,
            REGION_CODE_Malawi,
            REGION_CODE_Mali,
            REGION_CODE_Mauritania,
            REGION_CODE_Mauritius,
            REGION_CODE_Morocco,
            REGION_CODE_Mozambique,
            REGION_CODE_Namibia,
            REGION_CODE_Niger,
            REGION_CODE_Nigeria,
            REGION_CODE_Congo,
            REGION_CODE_Rwanda,
//            REGION_CODE_Western_Sahara,
            REGION_CODE_Sao_Tome_and_Principe,
            REGION_CODE_Senegal,
            REGION_CODE_Seychelles,
            REGION_CODE_Sierra_Leone,
            REGION_CODE_Somalia,
            REGION_CODE_South_Africa,
            REGION_CODE_South_Sudan,
            REGION_CODE_Sudan,
            REGION_CODE_Tanzania,
            REGION_CODE_Togo,
            REGION_CODE_Tunisia,
            REGION_CODE_Uganda,
            REGION_CODE_Zambia,
        REGION_CODE_Zimbabwe:
            return REGION_CODE_African_Union
            
        default:
            return nil
        } // switch self
    } // var superregionCode
} // extension String


// MARK:  -

extension String {
    func celestialBody(julianDay: JulianDay) -> CelestialBody? {
        switch self {
        case REGION_CODE_Sun:
            return Sun(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Mercury:
            return Mercury(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Venus:
            return Venus(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Moon:
            return Moon(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Mars:
            return Mars(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Jupiter:
            return Jupiter(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Saturn:
            return Saturn(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Uranus:
            return Uranus(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Neptune:
            return Neptune(julianDay: julianDay, highPrecision: true)
            
        default:
            return nil
        } // switch self
    }
} // extension String


// MARK:  -

extension String {
    var localeLanguageCode:  String? {
        let array = self.components(separatedBy: "_")
        if array.count < 1 {
            return nil
        }
        
        return array[0]
    } // var localeLanguageCode
    
    var localeRegionCode:  String? {
        let array = self.components(separatedBy: "_")
        let count: Int = array.count
        if count == 2 || count == 3 {
            let suspectedCountryCode = array[count - 1]
            if suspectedCountryCode.count != 2 && suspectedCountryCode.count != 3 {
                return nil
            }
            
            return suspectedCountryCode
        }
        
        return nil
    } // var localeRegionCode
    
    var localeCountryCodeFlag:  String {
        let countryCode = self.localeRegionCode
        if countryCode == nil {
            return "🏳️"
        }
        
        return countryCode!.flag
    } //var localeCountryCodeFlag
} // extension String


// MARK:  -

extension String {
    var backupWeekendDays: Array<Int> {
        // Because Apple didn’t make its code for weekends work right outside of the current location
        switch self {
        case REGION_CODE_Equatorial_Guinea,
            REGION_CODE_Germany,
            REGION_CODE_Hong_Kong,
            REGION_CODE_India,
            REGION_CODE_North_Korea,
            REGION_CODE_Uganda,
        REGION_CODE_Bolivia:
            return [1]
            
        case REGION_CODE_Brunei_Darussalam:
            return [6, 1]
            
        case REGION_CODE_Djibouti,
            REGION_CODE_Iran,
            REGION_CODE_Palestine,
        REGION_CODE_Somalia:
            return [6]
            
        case REGION_CODE_Afghanistan:
            return [5, 6]
            
        case REGION_CODE_Bangladesh,
            REGION_CODE_Algeria,
            REGION_CODE_Bahrain,
            REGION_CODE_Egypt,
            REGION_CODE_Iraq,
            REGION_CODE_Israel,
            REGION_CODE_Jordan,
            REGION_CODE_Kuwait,
            REGION_CODE_Libya,
            REGION_CODE_Maldives,
            REGION_CODE_Oman,
            REGION_CODE_Qatar,
            REGION_CODE_Saudi_Arabia,
            REGION_CODE_Sudan,
            REGION_CODE_Syria,
            REGION_CODE_Yemen,
        REGION_CODE_Malaysia:
            return [6, 7]
            
        case REGION_CODE_Nepal:
            return [7]
            
        default:
            return [7, 1]
        } // switch self
    } // var backupWeekendDays
} // extension String


// MARK:  -

let REGION_CODE_Sun     = "zsu"
let REGION_CODE_Mercury = "zme"
let REGION_CODE_Venus   = "zve"
let REGION_CODE_Earth   = "x"
let REGION_CODE_Moon    = "zmo"
let REGION_CODE_Mars    = "zma"
let REGION_CODE_Jupiter = "zju"
let REGION_CODE_Saturn  = "zsa"
let REGION_CODE_Uranus  = "zur"
let REGION_CODE_Neptune = "zne"
let REGION_CODE_Pluto   = "zpl"

let REGION_CODE_Northern_Hemisphere = "xb"
let REGION_CODE_Southern_Hemisphere = "xc"

let REGION_CODE_Afghanistan    = "AF"
let REGION_CODE_Aland_Islands    = "AX"
let REGION_CODE_Albania    = "AL"
let REGION_CODE_Algeria    = "DZ"
let REGION_CODE_American_Samoa    = "AS"
let REGION_CODE_Andorra    = "AD"
let REGION_CODE_Angola    = "AO"
let REGION_CODE_Anguilla    = "AI"
let REGION_CODE_Antarctica    = "AQ"
let REGION_CODE_Antigua_and_Barbuda    = "AG"
let REGION_CODE_Argentina    = "AR"
let REGION_CODE_Armenia    = "AM"
let REGION_CODE_Aruba    = "AW"
let REGION_CODE_Australia    = "AU"
let REGION_CODE_Austria    = "AT"
let REGION_CODE_Azerbaijan    = "AZ"
let REGION_CODE_Bahamas    = "BS"
let REGION_CODE_Bahrain    = "BH"
let REGION_CODE_Bangladesh    = "BD"
let REGION_CODE_Barbados    = "BB"
let REGION_CODE_Belarus    = "BY"
let REGION_CODE_Belgium    = "BE"
let REGION_CODE_Belize    = "BZ"
let REGION_CODE_Benin    = "BJ"
let REGION_CODE_Bermuda    = "BM"
let REGION_CODE_Bhutan    = "BT"
let REGION_CODE_Bolivia    = "BO"
let REGION_CODE_Bonaire_Sint_Eustatius_and_Saba    = "BQ"
let REGION_CODE_Bosnia_and_Herzegovina    = "BA"
let REGION_CODE_Botswana    = "BW"
let REGION_CODE_Bouvet_Island    = "BV"
let REGION_CODE_Brazil    = "BR"
let REGION_CODE_British_Indian_Ocean_Territory    = "IO"
let REGION_CODE_Brunei_Darussalam    = "BN"
let REGION_CODE_Bulgaria    = "BG"
let REGION_CODE_Burkina_Faso    = "BF"
let REGION_CODE_Burundi    = "BI"
let REGION_CODE_Cabo_Verde    = "CV"
let REGION_CODE_Cambodia    = "KH"
let REGION_CODE_Cameroon    = "CM"
let REGION_CODE_Canada    = "CA"
let REGION_CODE_Cayman_Islands    = "KY"
let REGION_CODE_Central_African_Republic    = "CF"
let REGION_CODE_Chad    = "TD"
let REGION_CODE_Chile    = "CL"
let REGION_CODE_China    = "CN"
let REGION_CODE_Christmas_Island    = "CX"
let REGION_CODE_Cocos_Islands    = "CC"
let REGION_CODE_Colombia    = "CO"
let REGION_CODE_Comoros    = "KM"
let REGION_CODE_Congo    = "CG"
let REGION_CODE_Democratic_Republic_of_the_Congo    = "CD"
let REGION_CODE_Cook_Islands    = "CK"
let REGION_CODE_Costa_Rica    = "CR"
let REGION_CODE_Cote_dIvoire    = "CI"
let REGION_CODE_Croatia    = "HR"
let REGION_CODE_Cuba    = "CU"
let REGION_CODE_Curacao    = "CW"
let REGION_CODE_Cyprus    = "CY"
let REGION_CODE_Czechia    = "CZ"
let REGION_CODE_Denmark    = "DK"
let REGION_CODE_Djibouti    = "DJ"
let REGION_CODE_Dominica    = "DM"
let REGION_CODE_Dominican_Republic    = "DO"
let REGION_CODE_Ecuador    = "EC"
let REGION_CODE_Egypt    = "EG"
let REGION_CODE_El_Salvador    = "SV"
let REGION_CODE_Equatorial_Guinea    = "GQ"
let REGION_CODE_Eritrea    = "ER"
let REGION_CODE_Estonia    = "EE"
let REGION_CODE_Eswatini    = "SZ"
let REGION_CODE_Ethiopia    = "ET"
let REGION_CODE_Falkland_Islands    = "FK"
let REGION_CODE_Faroe_Islands    = "FO"
let REGION_CODE_Fiji    = "FJ"
let REGION_CODE_Finland    = "FI"
let REGION_CODE_France    = "FR"
let REGION_CODE_French_Guiana    = "GF"
let REGION_CODE_French_Polynesia    = "PF"
let REGION_CODE_French_Southern_Territories    = "TF"
let REGION_CODE_Gabon    = "GA"
let REGION_CODE_Gambia    = "GM"
let REGION_CODE_Georgia    = "GE"
let REGION_CODE_Germany    = "DE"
let REGION_CODE_Ghana    = "GH"
let REGION_CODE_Gibraltar    = "GI"
let REGION_CODE_Greece    = "GR"
let REGION_CODE_Greenland    = "GL"
let REGION_CODE_Grenada    = "GD"
let REGION_CODE_Guadeloupe    = "GP"
let REGION_CODE_Guam    = "GU"
let REGION_CODE_Guatemala    = "GT"
let REGION_CODE_Guernsey    = "GG"
let REGION_CODE_Guinea    = "GN"
let REGION_CODE_Guinea_Bissau    = "GW"
let REGION_CODE_Guyana    = "GY"
let REGION_CODE_Haiti    = "HT"
let REGION_CODE_Heard_Island_and_McDonald_Islands    = "HM"
let REGION_CODE_Holy_See    = "VA"
let REGION_CODE_Honduras    = "HN"
let REGION_CODE_Hong_Kong    = "HK"
let REGION_CODE_Hungary    = "HU"
let REGION_CODE_Iceland    = "IS"
let REGION_CODE_India    = "IN"
let REGION_CODE_Indonesia    = "ID"
let REGION_CODE_Iran    = "IR"
let REGION_CODE_Iraq    = "IQ"
let REGION_CODE_Ireland    = "IE"
let REGION_CODE_Isle_of_Man    = "IM"
let REGION_CODE_Israel    = "IL"
let REGION_CODE_Italy    = "IT"
let REGION_CODE_Jamaica    = "JM"
let REGION_CODE_Japan    = "JP"
let REGION_CODE_Jersey    = "JE"
let REGION_CODE_Jordan    = "JO"
let REGION_CODE_Kazakhstan    = "KZ"
let REGION_CODE_Kenya    = "KE"
let REGION_CODE_Kiribati    = "KI"
let REGION_CODE_North_Korea    = "KP"
let REGION_CODE_South_Korea    = "KR"
let REGION_CODE_Kuwait    = "KW"
let REGION_CODE_Kyrgyzstan    = "KG"
let REGION_CODE_Laos    = "LA"
let REGION_CODE_Latvia    = "LV"
let REGION_CODE_Lebanon    = "LB"
let REGION_CODE_Lesotho    = "LS"
let REGION_CODE_Liberia    = "LR"
let REGION_CODE_Libya    = "LY"
let REGION_CODE_Liechtenstein    = "LI"
let REGION_CODE_Lithuania    = "LT"
let REGION_CODE_Luxembourg    = "LU"
let REGION_CODE_Macao    = "MO"
let REGION_CODE_Madagascar    = "MG"
let REGION_CODE_Malawi    = "MW"
let REGION_CODE_Malaysia    = "MY"
let REGION_CODE_Maldives    = "MV"
let REGION_CODE_Mali    = "ML"
let REGION_CODE_Malta    = "MT"
let REGION_CODE_Marshall_Islands    = "MH"
let REGION_CODE_Martinique    = "MQ"
let REGION_CODE_Mauritania    = "MR"
let REGION_CODE_Mauritius    = "MU"
let REGION_CODE_Mayotte    = "YT"
let REGION_CODE_Mexico    = "MX"
let REGION_CODE_Micronesia    = "FM"
let REGION_CODE_Moldova    = "MD"
let REGION_CODE_Monaco    = "MC"
let REGION_CODE_Mongolia    = "MN"
let REGION_CODE_Montenegro    = "ME"
let REGION_CODE_Montserrat    = "MS"
let REGION_CODE_Morocco    = "MA"
let REGION_CODE_Mozambique    = "MZ"
let REGION_CODE_Myanmar    = "MM"
let REGION_CODE_Namibia    = "NA"
let REGION_CODE_Nauru    = "NR"
let REGION_CODE_Nepal    = "NP"
let REGION_CODE_Netherlands    = "NL"
let REGION_CODE_New_Caledonia    = "NC"
let REGION_CODE_New_Zealand    = "NZ"
let REGION_CODE_Nicaragua    = "NI"
let REGION_CODE_Niger    = "NE"
let REGION_CODE_Nigeria    = "NG"
let REGION_CODE_Niue    = "NU"
let REGION_CODE_Norfolk_Island    = "NF"
let REGION_CODE_North_Macedonia    = "MK"
let REGION_CODE_Northern_Mariana_Islands    = "MP"
let REGION_CODE_Norway    = "NO"
let REGION_CODE_Oman    = "OM"
let REGION_CODE_Pakistan    = "PK"
let REGION_CODE_Palau    = "PW"
let REGION_CODE_Palestine    = "PS"
let REGION_CODE_Panama    = "PA"
let REGION_CODE_Papua_New_Guinea    = "PG"
let REGION_CODE_Paraguay    = "PY"
let REGION_CODE_Peru    = "PE"
let REGION_CODE_Philippines    = "PH"
let REGION_CODE_Pitcairn    = "PN"
let REGION_CODE_Poland    = "PL"
let REGION_CODE_Portugal    = "PT"
let REGION_CODE_Puerto_Rico    = "PR"
let REGION_CODE_Qatar    = "QA"
let REGION_CODE_Reunion    = "RE"
let REGION_CODE_Romania    = "RO"
let REGION_CODE_Russia    = "RU"
let REGION_CODE_Rwanda    = "RW"
let REGION_CODE_Saint_Barthelemy    = "BL"
let REGION_CODE_Saint_Helena_Ascension_and_Tristan_da_Cunha    = "SH"
let REGION_CODE_Saint_Kitts_and_Nevis    = "KN"
let REGION_CODE_Saint_Lucia    = "LC"
let REGION_CODE_Saint_Martin    = "MF"
let REGION_CODE_Saint_Pierre_and_Miquelon    = "PM"
let REGION_CODE_Saint_Vincent_and_the_Grenadines    = "VC"
let REGION_CODE_Samoa    = "WS"
let REGION_CODE_San_Marino    = "SM"
let REGION_CODE_Sao_Tome_and_Principe    = "ST"
let REGION_CODE_Sark    = "CQ"
let REGION_CODE_Saudi_Arabia    = "SA"
let REGION_CODE_Senegal    = "SN"
let REGION_CODE_Serbia    = "RS"
let REGION_CODE_Seychelles    = "SC"
let REGION_CODE_Sierra_Leone    = "SL"
let REGION_CODE_Singapore    = "SG"
let REGION_CODE_Sint_Maarten    = "SX"
let REGION_CODE_Slovakia    = "SK"
let REGION_CODE_Slovenia    = "SI"
let REGION_CODE_Solomon_Islands    = "SB"
let REGION_CODE_Somalia    = "SO"
let REGION_CODE_South_Africa    = "ZA"
let REGION_CODE_South_Georgia_and_the_South_Sandwich_Islands    = "GS"
let REGION_CODE_South_Sudan    = "SS"
let REGION_CODE_Spain    = "ES"
let REGION_CODE_Sri_Lanka    = "LK"
let REGION_CODE_Sudan    = "SD"
let REGION_CODE_Suriname    = "SR"
let REGION_CODE_Svalbard_and_Jan_Mayen    = "SJ"
let REGION_CODE_Sweden    = "SE"
let REGION_CODE_Switzerland    = "CH"
let REGION_CODE_Syria    = "SY"
let REGION_CODE_Taiwan    = "TW"
let REGION_CODE_Tajikistan    = "TJ"
let REGION_CODE_Tanzania    = "TZ"
let REGION_CODE_Thailand    = "TH"
let REGION_CODE_Timor_Leste    = "TL"
let REGION_CODE_Togo    = "TG"
let REGION_CODE_Tokelau    = "TK"
let REGION_CODE_Tonga    = "TO"
let REGION_CODE_Trinidad_and_Tobago    = "TT"
let REGION_CODE_Tunisia    = "TN"
let REGION_CODE_Turkey    = "TR"
let REGION_CODE_Turkmenistan    = "TM"
let REGION_CODE_Turks_and_Caicos_Islands    = "TC"
let REGION_CODE_Tuvalu    = "TV"
let REGION_CODE_Uganda    = "UG"
let REGION_CODE_Ukraine    = "UA"
let REGION_CODE_United_Arab_Emirates    = "AE"
let REGION_CODE_United_Kingdom    = "GB"
let REGION_CODE_United_States    = "US"
let REGION_CODE_United_States_Minor_Outlying_Islands    = "UM"
let REGION_CODE_Uruguay    = "UY"
let REGION_CODE_Uzbekistan    = "UZ"
let REGION_CODE_Vanuatu    = "VU"
let REGION_CODE_Venezuela    = "VE"
let REGION_CODE_Vietnam    = "VN"
let REGION_CODE_British_Virgin_Islands    = "VG"
let REGION_CODE_United_States_Virgin_Islands    = "VI"
let REGION_CODE_Wallis_and_Futuna    = "WF"
let REGION_CODE_Western_Sahara    = "EH"
let REGION_CODE_Yemen    = "YE"
let REGION_CODE_Zambia    = "ZM"
let REGION_CODE_Zimbabwe    = "ZW"

let REGION_CODE_Kosovo = "XK"

let REGION_CODE_European_Union    = "EU"
let REGION_CODE_United_Nations    = "UN"
let REGION_CODE_African_Union     = "African Union"

enum ASARegionCodeRegion: Int, CaseIterable, Identifiable {
    var id: Self { self }
    
    case regionNeutral                        =  0
    case internationalOrganizationsAndRegions =  1
    case AustraliaAndNewZealand               =  2
    case centralAsia                          =  3
    case easternAsia                          =  4
    case easternEurope                        =  5
    case LatinAmericaAndTheCaribbean          =  6
    case Melanesia                            =  7
    case Micronesia                           =  8
    case northernAfrica                       =  9
    case northernAmerica                      = 10
    case northernEurope                       = 11
    case Polynesia                            = 12
    case southEasternAsia                     = 13
    case southernAsia                         = 14
    case southernEurope                       = 15
    case subSaharanAfrica                     = 16
    case westernAsia                          = 17
    case westernEurope                        = 18
    
    var text: String {
        var raw = ""
        switch self {
            case .regionNeutral:
            raw = "ASARegionCodeRegion.allRegions"
            
        case .internationalOrganizationsAndRegions:
            raw = "ASARegionCodeRegion.international"
            
        case .AustraliaAndNewZealand:
            raw = "ASARegionCodeRegion.AustraliaAndNewZealand"
            
        case .centralAsia:
            raw = "ASARegionCodeRegion.centralAsia"
            
        case .easternAsia:
            raw = "ASARegionCodeRegion.easternAsia"
            
        case .easternEurope:
            raw = "ASARegionCodeRegion.easternEurope"
            
        case .LatinAmericaAndTheCaribbean:
            raw = "ASARegionCodeRegion.LatinAmericaAndTheCaribbean"
            
        case .Melanesia:
            raw = "ASARegionCodeRegion.Melanesia"
            
        case .Micronesia:
            raw = "ASARegionCodeRegion.Micronesia"
            
        case .northernAfrica:
            raw = "ASARegionCodeRegion.northernAfrica"
            
        case .northernAmerica:
            raw = "ASARegionCodeRegion.northernAmerica"
            
        case .northernEurope:
            raw = "ASARegionCodeRegion.northernEurope"
            
        case .Polynesia:
            raw = "ASARegionCodeRegion.Polynesia"
            
        case .southEasternAsia:
            raw = "ASARegionCodeRegion.southEasternAsia"
            
        case .southernAsia:
            raw = "ASARegionCodeRegion.southernAsia"
            
        case .southernEurope:
            raw = "ASARegionCodeRegion.southernEurope"
            
        case .subSaharanAfrica:
            raw = "ASARegionCodeRegion.subSaharanAfrica"
            
        case .westernAsia:
            raw = "ASARegionCodeRegion.westernAsia"
            
        case .westernEurope:
            raw = "ASARegionCodeRegion.westernEurope"
        } // switch self
        return NSLocalizedString(raw, comment: "")
    } // var text: String
} // enum ASARegionCodeRegion

extension String {
    var regionCodeRegion: ASARegionCodeRegion {
        switch self {
        case REGION_CODE_United_Nations,
        REGION_CODE_European_Union, REGION_CODE_African_Union:
            return .internationalOrganizationsAndRegions
            
        case REGION_CODE_Afghanistan,
            REGION_CODE_Bangladesh,
            REGION_CODE_Bhutan,
            REGION_CODE_India,
            REGION_CODE_Iran,
            REGION_CODE_Maldives,
            REGION_CODE_Nepal,
            REGION_CODE_Pakistan,
        REGION_CODE_Sri_Lanka:
            return .southernAsia
            
        case REGION_CODE_Aland_Islands,
            REGION_CODE_Denmark,
            REGION_CODE_Estonia,
            REGION_CODE_Faroe_Islands,
            REGION_CODE_Finland,
            REGION_CODE_Guernsey,
            REGION_CODE_Iceland,
            REGION_CODE_Ireland,
            REGION_CODE_Isle_of_Man,
            REGION_CODE_Jersey,
            REGION_CODE_Latvia,
            REGION_CODE_Lithuania,
            REGION_CODE_Norway,
            REGION_CODE_Svalbard_and_Jan_Mayen,
            REGION_CODE_Sweden,
        REGION_CODE_United_Kingdom:
            return .northernEurope
            
        case REGION_CODE_Albania,
            REGION_CODE_Andorra,
            REGION_CODE_Bosnia_and_Herzegovina,
            REGION_CODE_Croatia,
            REGION_CODE_Gibraltar,
            REGION_CODE_Greece,
            REGION_CODE_Holy_See,
            REGION_CODE_Italy,
            REGION_CODE_Malta,
            REGION_CODE_Montenegro,
            REGION_CODE_North_Macedonia,
            REGION_CODE_Portugal,
            REGION_CODE_San_Marino,
            REGION_CODE_Serbia,
            REGION_CODE_Slovenia,
            REGION_CODE_Spain,
        REGION_CODE_Kosovo:
            return .southernEurope
            
        case REGION_CODE_Algeria,
            REGION_CODE_Egypt,
            REGION_CODE_Libya,
            REGION_CODE_Morocco,
            REGION_CODE_Sudan,
            REGION_CODE_Tunisia,
        REGION_CODE_Western_Sahara:
            return .northernAfrica
            
        case REGION_CODE_American_Samoa,
            REGION_CODE_Cook_Islands,
            REGION_CODE_French_Polynesia,
            REGION_CODE_Niue,
            REGION_CODE_Pitcairn,
            REGION_CODE_Samoa,
            REGION_CODE_Tokelau,
            REGION_CODE_Tonga,
            REGION_CODE_Tuvalu,
        REGION_CODE_Wallis_and_Futuna:
            return .Polynesia
            
        case REGION_CODE_Angola,
            REGION_CODE_Benin,
            REGION_CODE_Botswana,
            REGION_CODE_British_Indian_Ocean_Territory,
            REGION_CODE_Burkina_Faso,
            REGION_CODE_Burundi,
            REGION_CODE_Cabo_Verde,
            REGION_CODE_Cameroon,
            REGION_CODE_Central_African_Republic,
            REGION_CODE_Chad,
            REGION_CODE_Comoros,
            REGION_CODE_Congo,
            REGION_CODE_Democratic_Republic_of_the_Congo,
            REGION_CODE_Cote_dIvoire,
            REGION_CODE_Djibouti,
            REGION_CODE_Equatorial_Guinea,
            REGION_CODE_Eritrea,
            REGION_CODE_Eswatini,
            REGION_CODE_Ethiopia,
            REGION_CODE_French_Southern_Territories,
            REGION_CODE_Gabon,
            REGION_CODE_Gambia,
            REGION_CODE_Ghana,
            REGION_CODE_Guinea,
            REGION_CODE_Guinea_Bissau,
            REGION_CODE_Kenya,
            REGION_CODE_Lesotho,
            REGION_CODE_Liberia,
            REGION_CODE_Madagascar,
            REGION_CODE_Malawi,
            REGION_CODE_Mali,
            REGION_CODE_Mauritania,
            REGION_CODE_Mauritius,
            REGION_CODE_Mayotte,
            REGION_CODE_Mozambique,
            REGION_CODE_Namibia,
            REGION_CODE_Niger,
            REGION_CODE_Nigeria,
            REGION_CODE_Reunion,
            REGION_CODE_Rwanda,
            REGION_CODE_Saint_Helena_Ascension_and_Tristan_da_Cunha,
            REGION_CODE_Sao_Tome_and_Principe,
            REGION_CODE_Senegal,
            REGION_CODE_Seychelles,
            REGION_CODE_Sierra_Leone,
            REGION_CODE_Somalia,
            REGION_CODE_South_Africa,
            REGION_CODE_South_Sudan,
            REGION_CODE_Tanzania,
            REGION_CODE_Togo,
            REGION_CODE_Uganda,
            REGION_CODE_Zambia,
        REGION_CODE_Zimbabwe:
            return .subSaharanAfrica
            
        case REGION_CODE_Anguilla,
            REGION_CODE_Antigua_and_Barbuda,
            REGION_CODE_Argentina,
            REGION_CODE_Aruba,
            REGION_CODE_Bahamas,
            REGION_CODE_Barbados,
            REGION_CODE_Belize,
            REGION_CODE_Bolivia,
            REGION_CODE_Bonaire_Sint_Eustatius_and_Saba,
            REGION_CODE_Bouvet_Island,
            REGION_CODE_Brazil,
            REGION_CODE_Cayman_Islands,
            REGION_CODE_Chile,
            REGION_CODE_Colombia,
            REGION_CODE_Costa_Rica,
            REGION_CODE_Cuba,
            REGION_CODE_Curacao,
            REGION_CODE_Dominica,
            REGION_CODE_Dominican_Republic,
            REGION_CODE_Ecuador,
            REGION_CODE_El_Salvador,
            REGION_CODE_Falkland_Islands,
            REGION_CODE_French_Guiana,
            REGION_CODE_Grenada,
            REGION_CODE_Guadeloupe,
            REGION_CODE_Guatemala,
            REGION_CODE_Guyana,
            REGION_CODE_Haiti,
            REGION_CODE_Honduras,
            REGION_CODE_Jamaica,
            REGION_CODE_Martinique,
            REGION_CODE_Mexico,
            REGION_CODE_Montserrat,
            REGION_CODE_Nicaragua,
            REGION_CODE_Panama,
            REGION_CODE_Paraguay,
            REGION_CODE_Peru,
            REGION_CODE_Puerto_Rico,
            REGION_CODE_Saint_Barthelemy,
            REGION_CODE_Saint_Kitts_and_Nevis,
            REGION_CODE_Saint_Lucia,
            REGION_CODE_Saint_Martin,
            REGION_CODE_Saint_Vincent_and_the_Grenadines,
            REGION_CODE_Sint_Maarten,
            REGION_CODE_South_Georgia_and_the_South_Sandwich_Islands,
            REGION_CODE_Suriname,
            REGION_CODE_Trinidad_and_Tobago,
            REGION_CODE_Turks_and_Caicos_Islands,
            REGION_CODE_Uruguay,
            REGION_CODE_Venezuela,
            REGION_CODE_British_Virgin_Islands,
        REGION_CODE_United_States_Virgin_Islands:
            return .LatinAmericaAndTheCaribbean
            
        case REGION_CODE_Antarctica:
            return .internationalOrganizationsAndRegions
            
        case REGION_CODE_Armenia,
            REGION_CODE_Azerbaijan,
            REGION_CODE_Bahrain,
            REGION_CODE_Cyprus,
            REGION_CODE_Georgia,
            REGION_CODE_Iraq,
            REGION_CODE_Israel,
            REGION_CODE_Jordan,
            REGION_CODE_Kuwait,
            REGION_CODE_Lebanon,
            REGION_CODE_Oman,
            REGION_CODE_Palestine,
            REGION_CODE_Qatar,
            REGION_CODE_Saudi_Arabia,
            REGION_CODE_Syria,
            REGION_CODE_Turkey,
            REGION_CODE_United_Arab_Emirates,
        REGION_CODE_Yemen:
            return .westernAsia
            
        case REGION_CODE_Australia,
            REGION_CODE_Christmas_Island,
            REGION_CODE_Cocos_Islands,
            REGION_CODE_Heard_Island_and_McDonald_Islands,
            REGION_CODE_New_Zealand,
        REGION_CODE_Norfolk_Island:
            return .AustraliaAndNewZealand
            
        case REGION_CODE_Austria,
            REGION_CODE_Belgium,
            REGION_CODE_France,
            REGION_CODE_Germany,
            REGION_CODE_Liechtenstein,
            REGION_CODE_Luxembourg,
            REGION_CODE_Monaco,
            REGION_CODE_Netherlands,
        REGION_CODE_Switzerland:
            return .westernEurope
            
        case REGION_CODE_Belarus,
            REGION_CODE_Bulgaria,
            REGION_CODE_Czechia,
            REGION_CODE_Hungary,
            REGION_CODE_Moldova,
            REGION_CODE_Poland,
            REGION_CODE_Romania,
            REGION_CODE_Russia,
            REGION_CODE_Slovakia,
        REGION_CODE_Ukraine:
            return .easternEurope
            
        case REGION_CODE_Bermuda,
            REGION_CODE_Canada,
            REGION_CODE_Greenland,
            REGION_CODE_Saint_Pierre_and_Miquelon,
        REGION_CODE_United_States:
            return .northernAmerica
            
        case REGION_CODE_Brunei_Darussalam,
            REGION_CODE_Cambodia,
            REGION_CODE_Indonesia,
            REGION_CODE_Laos,
            REGION_CODE_Malaysia,
            REGION_CODE_Myanmar,
            REGION_CODE_Philippines,
            REGION_CODE_Singapore,
            REGION_CODE_Thailand,
            REGION_CODE_Timor_Leste,
        REGION_CODE_Vietnam:
            return .southEasternAsia
            
        case REGION_CODE_China,
            REGION_CODE_Hong_Kong,
            REGION_CODE_Japan,
            REGION_CODE_North_Korea,
            REGION_CODE_South_Korea,
            REGION_CODE_Macao,
            REGION_CODE_Mongolia,
        REGION_CODE_Taiwan:
            return .easternAsia
            
        case REGION_CODE_Fiji,
            REGION_CODE_New_Caledonia,
            REGION_CODE_Papua_New_Guinea,
            REGION_CODE_Solomon_Islands,
        REGION_CODE_Vanuatu:
            return .Melanesia
            
        case REGION_CODE_Guam,
            REGION_CODE_Kiribati,
            REGION_CODE_Marshall_Islands,
            REGION_CODE_Micronesia,
            REGION_CODE_Nauru,
            REGION_CODE_Northern_Mariana_Islands,
            REGION_CODE_Palau,
        REGION_CODE_United_States_Minor_Outlying_Islands:
            return .Micronesia
            
        case REGION_CODE_Kazakhstan,
            REGION_CODE_Kyrgyzstan,
            REGION_CODE_Tajikistan,
            REGION_CODE_Turkmenistan,
        REGION_CODE_Uzbekistan:
            return .centralAsia
            
        default: return .regionNeutral
        }
    }
}


// MARK:  -

extension Character {
    var isSyntaxCharacter: Bool {
        switch self {
        case "A"..."Z", "a"..."z":
            return true
            
        default:
            return false
        }
    }
}

extension String {
    private enum ComponentizationMode {
        case symbol
        case literal
    } // enum ComponentizationMode
    
    var dateFormatPatternComponents: Array<ASADateFormatPatternComponent> {
        var buffer: String = ""
        var lastCharacter: Character? = nil
        var mode = ComponentizationMode.symbol
        var components: Array<ASADateFormatPatternComponent> = []
        var quoteMode = false
        
        for scalar in self.unicodeScalars { // We are doing this slightly weird thing, because at least one date format pattern puts a combining accent immediately after a quote symbol, and we need to make sure that we get the quote and the combining accent separately.
            let character = Character(scalar)
            if buffer.isEmpty {
                buffer.append(character)
                //                debugPrint(#file, #function, "Buffer is now “\(buffer)”, Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
            } else if character == "'" {
                if mode == .symbol {
                    let newComponent = ASADateFormatPatternComponent(type: .symbol, string: buffer)
                    components.append(newComponent)
                    //                    debugPrint(#file, #function, "Appending symbol component “\(buffer)”")
                    buffer = ""
                } else {
                    assert(mode == .literal)
                    if lastCharacter == "'" {
                        buffer.append(character)
                    }
                }
                
                mode = .literal
                quoteMode = !quoteMode
                //                debugPrint(#file, #function, "Buffer is now “\(buffer)”, Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
            } else if mode == .symbol {
                if character == lastCharacter {
                    buffer.append(character)
                    //                    debugPrint(#file, #function, "Buffer is now “\(buffer)”, Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
                } else {
                    let newComponent = ASADateFormatPatternComponent(type: .symbol, string: buffer)
                    components.append(newComponent)
                    //                    debugPrint(#file, #function, "Appending symbol component “\(buffer)”")
                    buffer = String(character)
                    mode = character.isSyntaxCharacter ? .symbol : .literal
                    //                    debugPrint(#file, #function, "Buffer is now “\(buffer)”, Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
                }
            } else if mode == .literal {
                if character.isSyntaxCharacter && !quoteMode {
                    let newComponent = ASADateFormatPatternComponent(type: .literal, string: buffer)
                    components.append(newComponent)
                    //                    debugPrint(#file, #function, "Appending literal component “\(buffer)”")
                    buffer = String(character)
                    mode = .symbol
                    //                    debugPrint(#file, #function, "Buffer is now “\(buffer)”, Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
                } else {
                    buffer.append(character)
                    //                    debugPrint(#file, #function, "Buffer is now “\(buffer)”, Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
                }
            }
            
            lastCharacter = character
        } // self.forEach
        
        let newComponent = ASADateFormatPatternComponent(type: mode == .literal ? .literal : .symbol, string: buffer)
        components.append(newComponent)
        //                            debugPrint(#file, #function, "Mode is now ", mode == .literal ? "literal" : "symbol")
        
        return components
    } // var dateFormatPatternComponents
} // extension String


// MARK:  -

extension String {
    var withStraightenedCurlyQuotes: String {
        return self.replacingOccurrences(of: "‘", with: "'").replacingOccurrences(of: "’", with: "'").replacingOccurrences(of: "“", with: "").replacingOccurrences(of: "”", with: "")
    }
} // extension String
