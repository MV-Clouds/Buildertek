/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_UIConfig
* Created by Sagar: 04/08/2017
*
* Utility class to provide UI Configuration infrastructure.
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_UIConfig {
    public static Map<String, String> msgMap = new Map<String, String> {
        BT_Constants.MSG_NO_RECORDS_FOUND => System.Label.No_Records_Found,
        BT_Constants.MSG_NO_RECORDS_SELECTED => System.Label.No_Records_Selected
    };
    
    /*
    To get icon in dynatree 
    */
    public static String getNodeIconImage(String objType, Boolean isPlural, Id id, String recordTypeName, sObject obj){
        if(objType == null){
            return '';
        }
        String iconSrcImageName = '';
        if(objType.equalsIgnoreCase('Folder__c')){
            return '';
        } else if(objType.equalsIgnoreCase('File__c')){
            iconSrcImageName = 'fileIcons/';
            String icon = obj != null && obj.get('Extension__c') != null ? BT_Constants.FILE_ICON_MAP.get((String.valueOf(obj.get('Extension__c')).toLowerCase())) : null;
            if(icon == null || icon == ''){
                icon = 'file.png';
            }
            iconSrcImageName += icon;
        } else {
            if(objType == 'User'){
                iconSrcImageName = 'icons/asset-people.png';
            } else if(objType == 'Group'){
                iconSrcImageName = 'icons/Dark_Blue_Bg.png';
            }  else if(objType == 'Account'){
                iconSrcImageName = 'icons/Account.png';
            }  else if(objType == 'Contact'){
                iconSrcImageName = 'icons/Dark_Blue_Bg.png';
            }  else{
                iconSrcImageName = 'icons/Dark_Blue_Bg.png';
            }
        }
        return iconSrcImageName;
    }
            
     public static String getConfiguredName(String name, String sObjId) {
        String configuredName = msgMap.get(name);
        return configuredName != null ? configuredName : name;
    }    
}