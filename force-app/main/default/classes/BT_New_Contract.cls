/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  20-Sep-2017
*/
public with sharing class BT_New_Contract {
    
    @AuraEnabled
    public static String getsObjName(String recordId){
    	return BT_UTILS.getSobjectTypeFromKeyPrefix(recordId.subString(0, 3));
    }
}