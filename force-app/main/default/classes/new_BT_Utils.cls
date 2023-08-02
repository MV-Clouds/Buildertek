/* **************************************************************************
* Copyright 2022-2023, BuilderTek
* All rights reserved
*
* Util Class: new_BT_Utils
* reCreated by MV Clouds: 04/07/2023
*
* - All util functions..

* - Modifications:
* - 04/07/2023 – Copy of Original BT_Utils
************************************************************************** */
public with sharing class new_BT_Utils {

    /**
     Converts nvPairsString into Map
     The nvPairsString can be of the form Name#Vaue~N2#V2... where ^ is nvSeparator and ~ is pairSeparator
     @param nvPairsString (name, value) pairs in specified format
     @param nvSeparator - name, value separator charactor
     @param pairSeparator - pairs separator charactor
     **/
    public static Map<String, String> convertNVStringToMap(String nvPairsString, String nvSeparator, String pairSeparator){
        // queryNVPairs is in the form of Name#Vaue~N2#V2... prepare queryString map of (n,v)
        Map<String, String> pairMap = new Map<String, String>();
        if (nvPairsString != null && nvPairsString != ''){
            List<String> nvPairs = nvPairsString.split(pairSeparator);
            for (String nvP : nvPairs){
                if (nvP != ''){
                    List<String> nv = nvP.split(nvSeparator);
                    if (nv.size() > 1){
                        pairMap.put(nv.get(0), nv.get(1));
                    }
                }
            }
        }
        return pairMap;
    }

    /*
     *   Executed:   From any class.
     *   Purpose:    Funxtion will return the Object type using object name
     *   Parameters: object name
     *   UnitTests:
     */
    public static Schema.Sobjecttype getObjectTypeFromTypeName(String typeName){
        return getObjectTypeFromTypeName(typeName, false);
    }

    /*
     *   Executed:   From any class.
     *   Purpose:    Funxtion will return the Object type using object name
     *   Parameters: object name
     *   UnitTests:
     */
    public static Schema.Sobjecttype getObjectTypeFromTypeName(String typeName, Boolean nullOk){
        String updatedTypeName = new_BT_Constants.OBJECT_NAMESPACE_MAP.get(typeName);
        if (updatedTypeName == null){
            updatedTypeName = typeName;
        }
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.Sobjecttype st = gd.get(updatedTypeName);
        return st;
    }

    /*
     *   Executed:   From any class.
     *   Purpose:    Function will return comma seperated list of field api for object. we can use this string into query string
     *   Parameters: object name
     *   UnitTests:
     */
    public static string getQueryStringForObjectWithAllFields(String objectType){
        String queryString;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.Sobjecttype sot = new_BT_Utils.getObjectTypeFromTypeName(objectType);
        if (sot != null){
            Schema.DescribeSObjectResult dr = sot.getDescribe();
            // all fields of attestation object
            Map<String, Schema.SObjectField> fields = dr.fields.getMap();
            integer i = 0;
            queryString = ' ';
            for (String field : fields.keyset()){
                if (i == 0){
                    queryString += field;
                } else{
                    queryString += ', ' + field;
                }
                i++;
            }
        }
        system.debug('queryString ----------> ' + queryString);
        return queryString;
    }
}