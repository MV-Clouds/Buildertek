/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Controller Class: BT_HomeController
* Created by Sagar: 06/05/2017
*
* - Showing the list of all documents and also allowed to perform various operation on those documents.

* - Modifications:
* - Sagar, 06/05/2017 – Initial Development
************************************************************************** */
public with sharing class BT_HomeController {
    public BT_FileExplorerComponentController.FileExplorePageConfguration fileExplorerPageConfugration {get; set;}
    public String retURL{get;set;}
    public String folderIdToLoad{get; set;}
    public String strMainObjectFieldAPI{get; set;}
    public String strMainObjectId{get; set;}
    public string strOtherObjectId{get; set;}
    public String strOtherObjectFieldAPI{get; set;}
    public String strCallerName{get;set;}
    public String strExplorerConfigName{get; set;}
    
    public BT_HomeController(ApexPages.StandardController controller){}
    
    public BT_HomeController(){
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        folderIdToLoad = ApexPages.CurrentPage().getParameters().get('folderIdToLoad');
        strMainObjectFieldAPI = BT_Utils.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('mainObjectFieldAPI'));
        strMainObjectId = BT_Utils.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('mainObjectId'));
        if(ApexPages.CurrentPage().getParameters().get('otherObjectFieldAPI') != null) {
            strOtherObjectFieldAPI = BT_Utils.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('otherObjectFieldAPI'));
        }
        if(ApexPages.CurrentPage().getParameters().get('otherObjectId') != null) {
            strOtherObjectId = BT_Utils.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('otherObjectId'));
        }
        strCallerName = ApexPages.currentPage().getParameters().get('callerName');
        if(ApexPages.currentPage().getParameters().get('explorerConfig') != null) {
            strExplorerConfigName = ApexPages.currentPage().getParameters().get('explorerConfig');
        }
        if(strExplorerConfigName != null && strExplorerConfigName != ''){
            fileExplorerPageConfugration = BT_HomeUtils.getFileExplorerPageConfiguration(strExplorerConfigName);
        } else{
            fileExplorerPageConfugration = BT_HomeUtils.getFileExplorerPageConfiguration(strMainObjectFieldAPI);
        }
    }
}