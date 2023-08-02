/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_SoqlBuilder
* Created by Sagar: 04/08/2017
*
* Util class for soql query builder
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_SoqlBuilder{
    
    private Set<Object>     selectx     = null;
    private Boolean         selectAll   = false;
    private Boolean         selectCount = false;
    private Boolean         selectAvg   = false;
    private Boolean         selectSum   = false;
    private Boolean         selectMin   = false;
    private Boolean         selectMax   = false;
    private String          aggx        = null;  
    private String          fromx       = null;
    private BT_SoqlCondition       wherex      = null;
    private List<BT_SoqlOrderBy>  orderByx    = null;
    private String          groupByx    = null;
    private Integer         limitx      = null;
    
    public enum Operator {
    
        //===============================
        // FIELD OPERATORS
        //===============================
        EQUALS,                   // =
        NOT_EQUALS,               // !=
        LESS_THAN,                // <
        LESS_THAN_OR_EQUAL_TO,    // <=
        GREATER_THAN,             // >
        GREATER_THAN_OR_EQUAL_TO, // >=
        LIKEX,                    // like
        
        //===============================
        // SET OPERATORS
        //===============================
        INCLUDES,                 // includes
        EXCLUDES,                 // excludes
        INX,                      // in
        NOT_IN                    // not in 
    
    }
        
    public BT_SoqlBuilder(){}
    
    public BT_SoqlBuilder selectAll(){
        selectAll = true;
        return this;
    }
    
    public BT_SoqlBuilder selectx(String field){ 
        return addToSelect(field);
    }
    
    public BT_SoqlBuilder selectx(BT_SoqlBuilder field){ 
        return addToSelect(field);
    }
    
    public BT_SoqlBuilder selectx(List<Object> fields){ 
        Set<Object> setFields = new Set<Object>();
        setFields.addAll(fields);
        return selectx(setFields);
    }
    
    public BT_SoqlBuilder selectx(Set<Object> fields){ 
        if(fields != null && fields.size() > 0){
            for(Object field : fields){
                addToSelect(field);
            }
        }
        return this;
    }

    public BT_SoqlBuilder selectx(List<String> fields){ 
        Set<String> setFields = new Set<String>();
        setFields.addAll(fields);
        return selectx(setFields);
    }
    
    public BT_SoqlBuilder selectx(Set<String> fields){ 
        if(fields != null && fields.size() > 0){
            for(String field : fields){
                addToSelect(field);
            }
        }
        return this;
    }

    private BT_SoqlBuilder addToSelect(Object field){
        if(field == null){
            throw new BT_ApplicationException('null field');
        }
        if(field instanceof String){
            if(selectx == null){
                selectx = new Set<Object>();
            }
            selectx.add(field);
        } else {
            throw new BT_ApplicationException('Invalid field type.  A field must be a String.');
        }
        this.selectCount = false;
        return this;
    }

    public BT_SoqlBuilder selectCount(){ 
        return selectCountx();
    }

    public BT_SoqlBuilder selectCountx(){ 
        this.selectCount = true;
        return this;
    }

    public BT_SoqlBuilder selectCount(String aggx){ 
        this.aggx = aggx;
        return selectCountx();
    }

    public BT_SoqlBuilder selectAveragex(String aggx){ 
        this.selectAvg = true;
        this.aggx = aggx;
        return this;
    }

    public BT_SoqlBuilder selectSumx(String aggx){ 
        this.selectSum = true;
        this.aggx = aggx;
        return this;
    }

    public BT_SoqlBuilder selectMinx(String aggx){ 
        this.selectMin = true;
        this.aggx = aggx;
        return this;
    }

    public BT_SoqlBuilder selectMaxx(String aggx){ 
        this.selectMax = true;
        this.aggx = aggx;
        return this;
    }

    public BT_SoqlBuilder fromx(String fromx){
        this.fromx = fromx; 
        return this;
    }

    public BT_SoqlBuilder wherex(BT_SoqlCondition wherex){ 
        this.wherex = wherex;
        return this;
    }
    
    public BT_SoqlBuilder orderByx(BT_SoqlOrderBy orderByx){ 
        if(this.orderByx == null){
            this.orderByx = new List<BT_SoqlOrderBy>();
        }
        this.orderByx.add(orderByx);
        return this;
    }

    public BT_SoqlBuilder orderByx(List<BT_SoqlOrderBy> orderByx){ 
        if(orderByx != null && orderByx.size() > 0){
            for(BT_SoqlOrderBy field : orderByx){
                orderByx(field);
            }
        }
        return this;
    }
    
   public BT_SoqlBuilder groupByx(String groupByx){
        this.groupByx = groupByx; 
        return this;
    }

    public BT_SoqlBuilder limitx(Integer limitx){
        this.limitx = limitx; 
        return this;
    }    
    
    public String toSoql(){ return this.toSoql(null); }
    
    public String toSoql(BT_SoqlOptions options){
        
        if(options == null){
            options = BT_SoqlOptions.DEFAULT_OPTIONS;
        }
        if(fromx == null || fromx == ''){
            throw new BT_ApplicationException('Illegal state!  You must invoke fromx() with valid object name before invoking toSoql().');
        }
        Boolean isFirst = true;
        String soql = 'SELECT ';
        if(selectx == null){
            selectx = new Set<Object>();
        }
        if(this.selectCount != null && this.selectCount && aggx == null){
            soql += 'COUNT()';
        } else if (this.selectCount != null && this.selectCount) {  
                soql += 'COUNT(' + String.escapeSingleQuotes(aggx) + ')';
        } else if (this.selectAvg != null && this.selectAvg){
                soql += 'AVG(' + String.escapeSingleQuotes(aggx) + ')';
        } else if (this.selectSum != null && this.selectSum){
                soql += 'SUM(' + String.escapeSingleQuotes(aggx) + ')';
        } else if (this.selectMin != null && this.selectMin) {
                soql += 'MIN(' + String.escapeSingleQuotes(aggx) + ')';
        } else if (this.selectMax != null && this.selectMax) {
                soql += 'MAX(' + String.escapeSingleQuotes(aggx) + ')';
        } else {
            if(this.selectAll){
                selectx.addAll(getAllFieldNames(String.escapeSingleQuotes(fromx)));
            }
            if(selectx.size() <= 0){
                selectx.add('id');
            }
            String distinctField = null;
            Map<String,String> distinctFields = new Map<String,String>();
            for(Object value : selectx){
                if(value instanceof BT_SoqlBuilder){
                    distinctField = '(' + ((BT_SoqlBuilder)value).toSoql(options) + ')';
                } else {
                    distinctField = ''+value;
                }
                distinctField = distinctField.trim();
                distinctFields.put(distinctField.toLowerCase(),distinctField);
            }
            
            Boolean firstField = true;
            for(String oneField : distinctFields.values()){
                if(oneField == null || oneField.trim() == ''){
                    continue;
                }
                if(firstField){
                    firstField = false;
                    soql += String.escapeSingleQuotes(oneField);
                } else {
                    soql += ',' + String.escapeSingleQuotes(oneField);
                }
            }
        }
        soql += ' FROM ' + String.escapeSingleQuotes(fromx);
        if(wherex != null){
            final String wherexs = wherex.toSoql(options);
            if(wherexs != null && wherexs != ''){  
                soql += ' WHERE ' + wherexs;
            } 
        }
          
        if(groupByx != null && groupByx != ''){
           soql += ' GROUP BY ' + String.escapeSingleQuotes(groupByx) + ' ';
        }
          
        if(orderByx != null && orderByx.size() > 0){
            isFirst = true;
            for(BT_SoqlOrderBy orderBy : orderByx){
                if(orderBy == null){
                    continue;
                }
                if(isFirst){  
                    isFirst = false;
                    soql += ' ORDER BY ';
                } else {
                    soql += ', ';
                }
                soql += orderBy.toSoql(options);
            }
        }
        if(limitx != null){
            soql += ' LIMIT ' + limitx;
        }
        
        soql = soql.replaceAll('\'true\'', 'true').replaceAll('\'false\'', 'false');

        return soql;
    }
    
    private static Set<Object> getAllFieldNames(String objectName){
        final Set<Object> returnValue = new Set<Object>();
        objectName = objectName.trim().toLowerCase();
            final Schema.SObjectType objectToken = BT_Utils.getObjectTypeFromTypeName(objectName);
            if(objectToken != null){
                final Map<String,Schema.SObjectField> fieldNameToFieldIndex = objectToken.getDescribe().fields.getMap();
                if(fieldNameToFieldIndex != null && fieldNameToFieldIndex.size() > 0){
                    for(String fieldName : fieldNameToFieldIndex.keySet()){
                        returnValue.add(fieldNameToFieldIndex.get(fieldName).getDescribe().getName());
                    }
                }
            }
        return returnValue;
    }
    
    
}