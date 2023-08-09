/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_SoqlOptions
* Created by Sagar: 04/08/2017
*
* SOQL option class
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_SoqlOptions {

    public static BT_SoqlOptions DEFAULT_OPTIONS = new BT_SoqlOptions();
     
    public Boolean escapeSingleQuotes {get;set;}
    public Boolean wildcardStringsInLikeOperators {get;set;}
    
    public BT_SoqlOptions(){
        escapeSingleQuotes();
        doNotWildcardStringsInLikeOperators();
    }
    
    public BT_SoqlOptions wildcardStringsInLikeOperators(){
        this.wildcardStringsInLikeOperators = true;
        return this;
    }
    
    public BT_SoqlOptions doNotWildcardStringsInLikeOperators(){
        this.wildcardStringsInLikeOperators = false;
        return this;
    }
    
    public BT_SoqlOptions escapeSingleQuotes(){
        this.escapeSingleQuotes = true;
        return this;
    }
    
    public BT_SoqlOptions doNotEscapeSingleQuotes(){
        this.escapeSingleQuotes = false;
        return this;
    }
}