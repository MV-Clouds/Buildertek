/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  06-Mar-2018
*/
global with sharing class BT_AutoCompleteComponentController {
    public String labelFieldVar{ get; set; }
    public String valueFieldVar{ get; set; }
    public String sObjVal{ get; set; }
    public Integer randomJsIden{ get; set; }
    public Object cacheField{ get; private set; }
    private Object targetFieldVar;

    public BT_AutoCompleteComponentController(){
        randomJsIden = getRandomNumber(1000000);
        sObjVal = 'Account';
        labelFieldVar = 'Name';
        valueFieldVar = 'Id';
    }

    /*Dummy setter Method*/
    public void setCacheField(Object cacheField){
    }

    public void setTargetFieldVar(Object targetFieldVar){
        if(targetFieldVar != this.targetFieldVar){
            cacheField = getCacheFieldValue(targetFieldVar);
            this.targetFieldVar = targetFieldVar;
        }
    }

    public Object getTargetFieldVar(){
        return targetFieldVar;
    }

    /**************************************************************************
       Purpose: Prepopulate the label field using the value field 
       Parameters: 
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    private Object getCacheFieldValue(Object targetFieldVar){
        Object retVal = targetFieldVar;
        if(targetFieldVar != null){
            if(valueFieldVar != labelFieldVar){
                for(sObject sObj : Database.query('SELECT ' + valueFieldVar + ',' + labelFieldVar + ' FROM ' + sObjVal + ' WHERE ' + valueFieldVar + ' =:targetFieldVar')){
                    retVal = sObj.get(labelFieldVar);
                    break;
                }
            } else {
                for(sObject sObj : Database.query('SELECT ' + labelFieldVar + ' FROM ' + sObjVal + ' WHERE ' + valueFieldVar + ' =:targetFieldVar')){
                    retVal = sObj.get(labelFieldVar);
                    break;
                }
            }
            return retVal;
        }
        return null;
    }

    /**************************************************************************
       Purpose: Random number generator to change the js function name if multiple components used
       Parameters: 
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    private Integer getRandomNumber(Integer size){
        Double d = Math.random() * size;
        return d.intValue();
    }

    /**************************************************************************
       Purpose: This method queries data according to the passed parameters
       Parameters: 
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    @RemoteAction
    global static List<Map<String, String>> getData(String sObjVal, String labelFieldVar, String valueFieldVar, String whereClauseVar, String param){
        Set<Map<String, String>> responses = new Set<Map<String, String>>();
        String soqlQuery = '';
        String valueField = valueFieldVar;
        param = String.escapeSingleQuotes(param);
        System.debug('sObjVal::'+sObjVal);
        System.debug('labelFieldVar::'+labelFieldVar);
        System.debug('valueFieldVar::'+valueFieldVar);
        System.debug('whereClauseVar::'+whereClauseVar);
        System.debug('param::'+param);
        if(sObjVal == 'User'){
            //If the object type is user then we need to show compnay or Account Name with user name.
            valueField = valueField + ', Account.Name, CompanyName';
        }

        if(valueFieldVar != labelFieldVar){
            soqlQuery = 'SELECT ' + valueField + ',' + labelFieldVar + ' FROM ' + sObjVal + ' WHERE ' + labelFieldVar + ' LIKE \'%' + param + '%\'' + (String.isNotBlank(whereClauseVar) ? ' AND ' + whereClauseVar : '');
            soqlQuery = soqlQuery+' ORDER BY NAME ASC';
            System.debug('Query::0:'+soqlQuery);
            for(Sobject sObj : Database.query(soqlQuery.replace('`', '\\\''))){

                String textValue = String.valueOf(sObj.get(labelFieldVar));
                if(sObjVal == 'User'){
                    //append the account or compnay name with user name.
                    String accontOrCompnayName = String.valueOf(sObj.getSObject('Account').get('Name')) != null ? String.valueOf(sObj.getSObject('Account').get('Name')) : String.valueOf(sObj.get('CompanyName'));
                    textValue = textValue + ' (' + accontOrCompnayName + ')';  
                }
                responses.add(new Map<String, String>{
                        'id' => String.valueOf(sObj.get(valueFieldVar)),
                        'text' => textValue
                });
            }
             system.debug('responses--'+responses);
        } else {
            soqlQuery = 'SELECT ' + valueField + ' FROM ' + sObjVal + ' WHERE ' + labelFieldVar + ' LIKE \'%' + param + '%\'' + (String.isNotBlank(whereClauseVar) ? ' AND ' + whereClauseVar : '');
            soqlQuery = soqlQuery+' ORDER BY NAME ASC';
            System.debug('Query::1:'+soqlQuery);
            for(Sobject sObj : Database.query(soqlQuery.replace('`', '\\\''))){

                String textValue = String.valueOf(sObj.get(labelFieldVar));
                if(sObjVal == 'User'){
                    //append the account or compnay name with user name.
                    String accontOrCompnayName = ' (' + String.valueOf(sObj.getSObject('Account').get('Name')) != null ? String.valueOf(sObj.getSObject('Account').get('Name')) : String.valueOf(sObj.get('CompanyName'));
                    textValue = textValue + ' (' + accontOrCompnayName + ')';
                }
                responses.add(new Map<String, String>{
                        'id' => String.valueOf(sObj.get(valueFieldVar)),
                        'text' => textValue
                });
            }
        }
        List<Map<String, String>> responseList = new List<Map<String, String>>();
        responseList.addAll(responses);
        system.debug('responseList---'+responseList);
        return responseList;
        
    }
}