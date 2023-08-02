/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_SoqlConditionGroup
* Created by Sagar: 04/08/2017
*
* Class for SOQL or condition
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public abstract with sharing class BT_SoqlConditionGroup implements BT_SoqlNestableCondition{
    
    public List<BT_SoqlCondition> conditions {get;private set;}
    
    private String separator {get;set;} 
    
    public BT_SoqlConditionGroup(String separator){
        this.separator = separator;
        this.conditions = new List<BT_SoqlCondition>();
    }
    
    public BT_SoqlNestableCondition add(BT_SoqlCondition c){
        if(c != null){
            this.conditions.add(c);
        }
        return this;
    }
    
    public String toSoql(){ return this.toSoql(null); }
    
    public String toSoql(BT_SoqlOptions options){
        if(options == null){
            options = BT_SoqlOptions.DEFAULT_OPTIONS;
        }
        String soql = '';
        if(conditions.size() == 1){
            return conditions.get(0).toSoql(options);
        } else if(conditions.size() > 1){
            Boolean hasOpenParenBeenAdded = false;
            String additionalSoql = null;
            for(BT_SoqlCondition condition : conditions){
                additionalSoql = condition.toSoql(options);
                if(additionalSoql == null || additionalSoql.trim() == ''){
                    continue;
                }
                if(hasOpenParenBeenAdded){
                    soql += ' ' + separator + ' ';
                } else {
                    soql = '(';
                    hasOpenParenBeenAdded = true;
                }
                soql += additionalSoql;
            }
            if(hasOpenParenBeenAdded){
                soql += ')';
            }
        }
        return soql;
    }
    
}