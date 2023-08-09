/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: TreeConfigurationDAO
* Created by Sagar: 04/08/2017
*
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_SoqlSetCondition implements BT_SoqlCondition{
    
    private static final BT_SoqlBuilder.Operator INCLUDES  = BT_SoqlBuilder.Operator.INCLUDES;
    private static final BT_SoqlBuilder.Operator EXCLUDES  = BT_SoqlBuilder.Operator.EXCLUDES;
    private static final BT_SoqlBuilder.Operator INX       = BT_SoqlBuilder.Operator.INX;
    private static final BT_SoqlBuilder.Operator NOT_IN    = BT_SoqlBuilder.Operator.NOT_IN;

    public String       field    {get; private set;}
    public BT_SoqlBuilder.Operator     operator {get; private set;}
    public List<Object> values   {get; private set;}
    public BT_SoqlBuilder  builder  {get; private set;}
    
    public BT_SoqlSetCondition(){}
    
    public BT_SoqlSetCondition(String field){
        this.field(field);
    }
    
    public BT_SoqlSetCondition(String field, BT_SoqlBuilder.Operator operator, List<Object> values){
        this.field(field);
        this.setOperation(operator,values);
    }
    
    public BT_SoqlSetCondition(String field, BT_SoqlBuilder.Operator operator, BT_SoqlBuilder builder){
        this.field(field);
        this.setOperation(operator,builder);
    }
    
    public BT_SoqlSetCondition field(String field){
        if(field == null || field.trim() == ''){
            throw new BT_ApplicationException('illegal argument:  field is empty');
        }
        this.field = field.trim();
        return this;
    }
    
    public BT_SoqlSetCondition includes(List<Object> values){ return setOperation(INCLUDES,values); }
    public BT_SoqlSetCondition excludes(List<Object> values){ return setOperation(EXCLUDES,values); }
    public BT_SoqlSetCondition inx     (List<Object> values){ return setOperation(INX,     values); }
    public BT_SoqlSetCondition notIn   (List<Object> values){ return setOperation(NOT_IN,  values); }

    public BT_SoqlSetCondition includes(BT_SoqlBuilder builder){ return setOperation(INCLUDES,builder); }
    public BT_SoqlSetCondition excludes(BT_SoqlBuilder builder){ return setOperation(EXCLUDES,builder); }
    public BT_SoqlSetCondition inx     (BT_SoqlBuilder builder){ return setOperation(INX,     builder); }
    public BT_SoqlSetCondition notIn   (BT_SoqlBuilder builder){ return setOperation(NOT_IN,  builder); }

    private BT_SoqlSetCondition setOperation(BT_SoqlBuilder.Operator operator, List<Object> values){
        if(values == null || values.size() <= 0){
            throw new BT_ApplicationException('illegal argument:  values is empty');
        }
        this.values = values;
        return setOperator(operator);
    }

    private BT_SoqlSetCondition setOperation(BT_SoqlBuilder.Operator operator, BT_SoqlBuilder builder){
        if(builder == null){
            throw new BT_ApplicationException('illegal argument:  builder is null');
        }
        this.builder = builder;
        return setOperator(operator);
    }
    
    private BT_SoqlSetCondition setOperator(BT_SoqlBuilder.Operator operator){
        if(operatorToString(operator) == null){
            throw new BT_ApplicationException('illegal operator: ' + operator);
        }
        this.operator = operator;
        return this;
    }

    public String toSoql(){ return this.toSoql(null); }
    
    public String toSoql(BT_SoqlOptions options){
        if(options == null){
            options = BT_SoqlOptions.DEFAULT_OPTIONS;
        }
        if(this.operator== null){
            throw new BT_ApplicationException(
               'Illegal state!  One of the following operations must be invoked on SetCondition prior to invoke toSoql(): (includes|excludes|inn|notIn)');
        }
        String insideParams = null;
        if(builder == null){ 
            Boolean firstObject = true;
            for(Object value : this.values){
                String stringValue = BT_SoqlUtils.toLiteral(value);
                if(stringValue == null){
                    continue;
                }
               if(firstObject){
                   firstObject = false;
                   insideParams = stringValue;
               } else {
                   insideParams += ',' + stringValue;
               }
            }
        } else  insideParams = builder.toSoql(options);
        return field + ' ' + operatorToString(operator) + ' (' + insideParams + ')'; 
    }

    public static String operatorToString(BT_SoqlBuilder.Operator operator){
        String returnValue = null;
        if(operator == INCLUDES){ returnValue = 'INCLUDES'; }       
        else if(operator == EXCLUDES){ returnValue = 'EXCLUDES'; }       
        else if(operator == INX){ returnValue = 'IN'; }       
        else if(operator == NOT_IN){ returnValue = 'NOT IN'; }       
        return returnValue;
    }

}