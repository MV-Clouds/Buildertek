public with sharing class QBReceiptJSON {
    
    public List<Line> Line;
    public Boolean sparse;
    public String PaymentRefNum;
    public CustomerRef CustomerRef;
    public ProjectRef ProjectRef;
    public String Id;
    public PaymentMethodRef PaymentMethodRef;
	public Date TxnDate;
    public MetaData MetaData;
    public String SyncToken;
    public Double TotalAmt;
    public class ProjectRef{
        public String value;
    }
    public class PaymentMethodRef{
        public String value;
    }
    public class MetaData{
        public String CreateTime;
        public String LastUpdatedTime;
    }
    public class LinkedTxn{
        public String TxnType;
        public String TxnId;
    }
    public class Line{
        public list<LinkedTxn> LinkedTxn;
        public Decimal Amount;
    }
    public class CustomerRef{
        public String value;
    }

    public static QBReceiptJSON parse(String json) {
        return (QBReceiptJSON) System.JSON.deserialize(json, QBReceiptJSON.class);
    }
}