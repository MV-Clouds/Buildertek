/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Class: TreePickerNode
*
* Created by Sagar
* - Modifications:
* - Sagar – Initial Development 
************************************************************************** */
public with sharing virtual class TreePickerNode {
    public Id id {get; set;}
    
    public String name {get; set;}
        
    public String fullPath {get; set;} // Store the full path of ids for selected node 
    
    public String objectType {get; set;} // to identify selection type Account, User, group TODO: Do not need this as we have added the link URL
    
    public String detailUrl {get; set;} // to open selected record detail
    
    public String icon {get; set;} // for display icon 
    
    public String idString;
    
    public Boolean checked {get; set;} // if true, the node is not selected any more
    
    public TreePickerNode() {
    
    }
    
    public TreePickerNode(Id id, String name) {
        this.id = id;
        this.name = name;
    }
    
    public TreePickerNode(Id id, String name, String fullPath, String Icon) {
        this.id = id;
        this.name = name;
        this.icon = icon;
        this.fullPath = fullPath;
    }
    
    public TreePickerNode(String idString, String name){
        this.idString = idString;
        this.name = name;
    }
    
    public TreePickerNode(String idString, String name, String fullPath){
        this.id = idString;
        this.idString = idString;
        this.name = name;
        if(fullPath != null && fullPath != ''){
            this.fullPath = fullPath.replace('\'','&#39;');
        } else {
            this.fullPath = fullPath;
        }   
    }
    
    public TreePickerNode(Id id, String name, Boolean checked) {
        this.id = id;
        this.name = name;
        this.checked = checked;
    }
}