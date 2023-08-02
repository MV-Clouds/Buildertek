/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_SoqlAndCondition
* Created by Sagar: 04/08/2017
*
* Class for SOQL Order by
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_SoqlOrderBy {

    public String field {get;set;}
    public Boolean ascending {get;set;}
    public Boolean descending {get{return !ascending;}}
    public Boolean nullsFirst {get;set;}
    public Boolean nullsLast {get{return !nullsFirst;}}
    private Boolean sortSet = false;
    private Boolean nullsSet = false;
    
    public BT_SoqlOrderBy(String field){
        if(field == null ||  field.trim() == ''){
            throw new BT_ApplicationException(System.Label.Empty_Field);
        }
        this.field = String.escapeSingleQuotes(field);
        this.ascending();
        this.sortSet = false;
    }
    
    public BT_SoqlOrderBy ascending (){ return setAscending(true); }
    public BT_SoqlOrderBy descending(){ return setAscending(false);}
    public BT_SoqlOrderBy nullsFirst(){ return setNullsFirst(true);}
    public BT_SoqlOrderBy nullsLast (){ return setNullsFirst(false);}
    
    private BT_SoqlOrderBy setAscending(Boolean ascending){
        this.ascending = ascending;
        this.sortSet = true;
        if(!this.nullsSet){
            this.nullsFirst = this.descending;
        }
        return this;
    }
    
    private BT_SoqlOrderBy setNullsFirst(Boolean nullsFirst){
        this.nullsFirst = nullsFirst;
        this.nullsSet = true;
        return this;
    }

    public String toSoql(){ return this.toSoql(null); }
    
    public String toSoql(BT_SoqlOptions options){
        if(options == null){
            options = BT_SoqlOptions.DEFAULT_OPTIONS;
        }
        String returnValue = this.field;
        if(sortSet){
            if(ascending) returnValue += ' ASC';
            else returnValue += ' DESC';
        }
        if(nullsSet){
            if(nullsFirst) returnValue += ' NULLS FIRST';
            else returnValue += ' NULLS LAST';
        }
        return returnValue;
    }
    

}