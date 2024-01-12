public without sharing class QBReceiptResponseJSON {

	public Payment Payment;
		// public String time;
	public class ProjectRef{
		public String value;
	}
	public class PaymentMethodRef{
		public String value;
	}
	public class Payment{
		public ProjectRef ProjectRef;
		public Boolean sparse;
		public String PaymentRefNum;
		public list<Line> Line;
		public Double TotalAmt;
		public CustomerRef CustomerRef;
		public Date TxnDate;
		public String Id;
		public Double UnappliedAmt;
		public PaymentMethodRef PaymentMethodRef;
		public String domain;
		public MetaData MetaData;
		public String SyncToken;
	}
	public class MetaData{
		public String CreateTime;
		public String LastUpdatedTime;
	}
	public class LinkedTxn{
		public String TxnId;
		public String TxnType;
	}
	public class Line{
		public list<LinkedTxn> LinkedTxn;
		public Double Amount;
	}
	public class CustomerRef{
		public String value;
	}

	public QueryResponse QueryResponse;
	public class QueryResponse{
		public Integer startPosition;
		public Integer maxResults;
		public list<Payment> Payment;
		public Integer totalCount;
	}

    public static QBReceiptResponseJSON parse(String json_Body) {
		return (QBReceiptResponseJSON) JSON.deserialize(json_Body, QBReceiptResponseJSON.class);
	}
}