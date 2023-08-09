/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_SoqlUtils
* Created by Sagar: 04/08/2017
*
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_SoqlFieldCondition implements BT_SoqlCondition{
    
    private static final BT_SoqlBuilder.Operator EQUALS                    = BT_SoqlBuilder.Operator.EQUALS;
    private static final BT_SoqlBuilder.Operator NOT_EQUALS                = BT_SoqlBuilder.Operator.NOT_EQUALS;
    private static final BT_SoqlBuilder.Operator LESS_THAN                 = BT_SoqlBuilder.Operator.LESS_THAN;
    private static final BT_SoqlBuilder.Operator LESS_THAN_OR_EQUAL_TO     = BT_SoqlBuilder.Operator.LESS_THAN_OR_EQUAL_TO;
    private static final BT_SoqlBuilder.Operator GREATER_THAN              = BT_SoqlBuilder.Operator.GREATER_THAN;
    private static final BT_SoqlBuilder.Operator GREATER_THAN_OR_EQUAL_TO  = BT_SoqlBuilder.Operator.GREATER_THAN_OR_EQUAL_TO;
    private static final BT_SoqlBuilder.Operator LIKEX                     = BT_SoqlBuilder.Operator.LIKEX;
    private static final BT_SoqlBuilder.Operator DEFAULT_OPERATOR          = EQUALS;
    
    public String   field        {get;private set;}
    public BT_SoqlBuilder.Operator operator    {get;private set;}
    public Object   value       {get;private set;}
    
    public BT_SoqlFieldCondition(){}    
    
    public BT_SoqlFieldCondition(String field){
        this.field(field);
    }
    
    public BT_SoqlFieldCondition(String field, Object value){
        this(field, DEFAULT_OPERATOR, value);
    }
    
    public BT_SoqlFieldCondition(String field, BT_SoqlBuilder.Operator operator, Object value){
        this.field(field);
        if(operator!= null){
            this.setOperation(operator,value);
        }
    }

    public BT_SoqlFieldCondition field(String field){
        if(field == null || field.trim() == ''){
            throw new BT_ApplicationException(System.Label.Illegal_Argument);
        }
        this.field = field.trim();
        return this;
    }

    public BT_SoqlFieldCondition equals              (Object value){ return setOperation(EQUALS                  ,value); }
    public BT_SoqlFieldCondition notEquals           (Object value){ return setOperation(NOT_EQUALS              ,value); }
    public BT_SoqlFieldCondition lessThan            (Object value){ return setOperation(LESS_THAN               ,value); }
    public BT_SoqlFieldCondition lessThanOrEqualTo   (Object value){ return setOperation(LESS_THAN_OR_EQUAL_TO   ,value); }
    public BT_SoqlFieldCondition greaterThan         (Object value){ return setOperation(GREATER_THAN            ,value); }
    public BT_SoqlFieldCondition greaterThanOrEqualTo(Object value){ return setOperation(GREATER_THAN_OR_EQUAL_TO,value); }
    public BT_SoqlFieldCondition likex               (Object value){ return setOperation(LIKEX                   ,value); }
    
    private BT_SoqlFieldCondition setOperation(BT_SoqlBuilder.Operator operator, Object value){
        if( operatorToString(operator) == null){
            throw new BT_ApplicationException(System.Label.Illegal_operator + operator);
        }
        this.operator = operator;
        this.value = value;
        return this;
    }

    public String toSoql(){ return this.toSoql(null); }
    
    public String toSoql(BT_SoqlOptions options){
        if(options == null){
            options = BT_SoqlOptions.DEFAULT_OPTIONS;
        }
        Object manipulated = value;
        if(    manipulated != null 
               && manipulated instanceof String 
               && operator == LIKEX
               && options.wildcardStringsInLikeOperators){ 
            manipulated = ensureStringStartsEndsWithChar( ((String)manipulated),'%');
        }
        return field + ' ' + operatorToString(operator) + ' ' + BT_SoqlUtils.toLiteral(manipulated,options);
    }
    
    private String ensureStringStartsEndsWithChar(String str, String charc){
        String returnStr = str;
        if(returnStr != null && charc != null){
            returnStr = str.startsWith(charc) ? returnStr : charc + returnStr;
            returnStr = str.endsWith(charc) ? returnStr : returnStr + charc;
        }
        return returnStr;
    }
    
    public static String operatorToString(BT_SoqlBuilder.Operator op){
        String returnValue = null;
        if(     op == EQUALS)                   { returnValue = '='; }       
        else if(op == NOT_EQUALS)               { returnValue = '!='; }       
        else if(op == LESS_THAN)                { returnValue = '<'; }       
        else if(op == LESS_THAN_OR_EQUAL_TO)    { returnValue = '<='; }       
        else if(op == GREATER_THAN)             { returnValue = '>'; }       
        else if(op == GREATER_THAN_OR_EQUAL_TO) { returnValue = '>='; }       
        else if(op == LIKEX)                    { returnValue = 'like'; }
        return returnValue;
    }
    
}