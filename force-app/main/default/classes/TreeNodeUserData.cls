/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Controller Class: TreeNodeUserData
* Created by Sagar: 10/05/2017
*
* Tree Node User data object, 
* contains data that app needs to move back-end forth between server-client for a tree node

* - Modifications:
* - Sagar, 06/05/2017 – Initial Development
************************************************************************** */ 
global class TreeNodeUserData {

    
    @AuraEnabled public String id{ get; set; } // node id, full path from parent hierarchy to this node
    @AuraEnabled public String key{ get; set; } // node key, it's individual id
    @AuraEnabled public String objectType{ get; set; } // object type of the object represented by the node
    @AuraEnabled public String recordType{ get; set; } // record type of the object represented by the node
    @AuraEnabled public String iconCls{ get; set; } // icon class

    @AuraEnabled public String nodeType{ get; set; } // indicats what type of the node is, can be one of the NODE_TYPE_*
    @AuraEnabled public String childObjectType{ get; set; } // child object type that could be retrieve for the group/query nodes
    @AuraEnabled public String titleFieldName{ get; set; } // name of the field that needs to be used as title field
    @AuraEnabled public String nodeQuery{ get; set; } // node query string #/~ separated (name, value) pairs to query in
    // the form Name#Vaue~N2#V2...
    @AuraEnabled public Boolean showGroupByCharts{ get; set; } // if set to true, shows group by charts
    @AuraEnabled public Boolean showResultObjectsInTree{ get; set; } // if set to true, show grouped by objects in tree. this can be used to hide/show
    // certain objects in tree e.g. show asset types as nodes in tree but not actual assets
    @AuraEnabled public Boolean showNewButton{ get; set; } // if set to true, shows new button on top of the grid
    @AuraEnabled public String tncId{ get; set; } // tree node configuration id if this is configured using the TNC schema
    @AuraEnabled public Boolean checkable{ get; set; } // if set to true, means this node is checkable, else not checkable so hide checkbox
    @AuraEnabled public String orderChildrenBy{ get; set; }
    @AuraEnabled public Boolean showOnlyPortalUser{ get; set; }
    @AuraEnabled public Boolean CustomerVisibility{ get; set; }
    @AuraEnabled public String queryParameters{ get; set; }
    @AuraEnabled public String adType{ get; set; } //Type of the authority document. For example it could be a audit guideline, contractula obligation etc.
    @AuraEnabled public sObject objSelectedRecord{ get; set; }
    @AuraEnabled public String totalOptions{ get; set; } 
    @AuraEnabled public String totalTestedOptions{ get; set; } 
    @AuraEnabled public Boolean isDue{ get; set; } 
    
    
    public String mainObjectFieldAPI{get; set;}
    public String mainObjectId{get; set;}
    public String otherObjectFieldAPI{get; set;}
    public String otherObjectId{get; set;}
    public String downloadUrl{get; set;}
}