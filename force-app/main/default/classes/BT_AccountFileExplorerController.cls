/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_AccountFileExplorerController
* Created by Sagar: 12/09/2017
*
* - Showing the list of all documents related to account.

* - Modifications:
* - Sagar, 12/09/2017 – Initial Development
************************************************************************** */
public with sharing class BT_AccountFileExplorerController{
    public String retURL{get;set;}
    public String strMainObjectFieldAPI{get; set;}
    public String strMainObjectId{get; set;}
    public string strOtherObjectId{get; set;}
    public String strOtherObjectFieldAPI{get; set;}
    public String strCallerName{get;set;}
    public BT_AccountFileExplorerController(ApexPages.StandardController controller) {
        Sobject  obj = controller.getRecord(); 
        if(obj != null && obj.Id != null){
            strMainObjectId = obj.Id;
            strMainObjectFieldAPI = BT_Utils.getNamespacePrefix()+'Account__c';
        }
    }
}