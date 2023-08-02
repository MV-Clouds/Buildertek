/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: avSoqlUtils
* Created by Sagar: 04/08/2017
*
* Utility class to provide utility methods for building SOQL queries
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_SoqlUtils {
    /*
    *   Purpose:    For a given object type and field list, build a select clause. If includeId is set to true, add
                    Id field to the select list.
    *   Parameters: objectType            
                    fields
                    includeId
    *   UnitTests:  
    */  
    public Static String buildSelectClause(String objectType, List<String> fields, Boolean includeId) {
        if(fields == null || fields.size() == 0){
            return '';
        }
        Boolean firstField = true;
        String soql = 'SELECT ';
        if(includeId){
            soql = soql + ' Id';
            firstField = false;
        }
        for(String field : fields){
            if(includeId && field.equals('Id')){
                continue;
            }
            if(!firstField){
                soql = soql + ', ';
            }
            soql = soql + String.escapeSingleQuotes(field);
            firstField = false;
        }
        soql = soql + ' FROM ' + objectType;
        return soql;
    }
    /*
    *   Purpose: Using the given fields, build an order by clause
    *   Parameters: fields            
                    ascending
    *   UnitTests:  
    */
    public Static String buildOrderByClause(List<String> fields, Boolean ascending) {
        if(fields == null || fields.size() == 0){
            return '';
        }
        Boolean firstField = true;
        String orderBy = ' ORDER BY ';
        for(String field : fields){
            if(!firstField){
                orderBy = orderBy + ', ';
            }
            orderBy = orderBy + field;
            firstField = false;
        }
        if(!ascending){
            orderBy = orderBy + ' DESC';
        }
        return orderBy;
    }
    /*
    *   Purpose: Given the order by string from a tree node, generate a SOQL order by clause.
    *   Parameters: orderChildrenBy 
    *   UnitTests:  
    */
    /*
    field1 => order by field1 ASC
    field1~field2 => order by field1 ASC, field2 ASC
    field1#ASC~field2 => order by field1 ASC, field2 ASC
    field1#DESC~field2 => order by field1 DESC, field2 ASC
    field1~field2#DESC => order by field1 ASC, field2 DESC
    field1#DESC~field2#DESC => order by field1 DESC, field2 DESC 
    */
    public static String buildSOQLOrderByClause(String orderChildrenBy) {
        if(orderChildrenBy == null || orderChildrenBy.length() == 0){
            return '';
        }
        String SOQLString = 'ORDER BY';
        //Get the fields
        String[] fields = orderChildrenBy.split(BT_Constants.SEPARATOR_NV_PAIR);
        for(String field : fields){
            if(field == null || field.trim().length() == 0){
                continue;
            }
            if(!SOQLString.equalsIgnoreCase('ORDER BY')){
                SOQLString += ',';
            }
            String[] items = field.trim().split(BT_Constants.SEPARATOR_NAME_VALUE);
            if(items.size() == 1){
                SOQLString += ' ' + String.escapeSingleQuotes(items.get(0)) + ' ASC';
            } else if(items.size() == 2){
                SOQLString += ' ' + String.escapeSingleQuotes(items.get(0)) + ' ' + items.get(1);
            } else {
                //This should not happen
                throw new BT_ApplicationException('Illegal order by definition ' + orderChildrenBy + ' for tree node ');
            }
        }
        if(SOQLString.equalsIgnoreCase('ORDER BY')){
            return '';
        }
        return SOQLString;
    }
    
    public static String toLiteral(final Object value){
        return toLiteral(value,null);
    }
    
    public static String toLiteral(final Object value, BT_SoqlOptions options){
        if(options == null){
            options = BT_SoqlOptions.DEFAULT_OPTIONS;
        }
        String literal = '';
        if(value == null){
            literal += 'null'; 
        } else if(  value instanceof BT_Soqlable ){
            return ((BT_Soqlable)value).toSoql(options);
        } else if(  value instanceof String  || value instanceOf ID){
            String manipulated = (String) value;
            if(options.escapeSingleQuotes == true){
                manipulated = String.escapeSingleQuotes(manipulated);
            }
            literal += '\'' + manipulated + '\''; 
        } else if(  value instanceOf Boolean ||
                    value instanceOf Integer || 
                    value instanceOf Long    || 
                    value instanceOf Double  || 
                    value instanceOf Decimal){
            literal += value;
        } else if(  value instanceOf Date){
            literal += Datetime.newInstance(((Date)value).year(), ((Date)value).month(), ((Date)value).day()).format('yyyy-MM-dd');
        } else if(  value instanceOf Datetime){
            literal += ((Datetime) value).format('yyyy-MM-dd') + 'T' + ((Datetime) value).format('hh:mm:ss') + 'Z';
        } else {
            throw new BT_ApplicationException('invalid value; value must be null, a primitive type ' 
                + '(String|ID|Boolean|Integer|Long|Double|Decimal|Date|Datetime), or implement BT_Soqlable interface');
        }
        return literal;
    }
}