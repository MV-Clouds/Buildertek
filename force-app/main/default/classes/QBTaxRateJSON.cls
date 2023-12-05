public without sharing class QBTaxRateJSON {
	public QueryResponse QueryResponse;

	public class TaxRateRef{
		public String name;
		public String value;
	}
	public class TaxRateDetail{
		public TaxRateRef TaxRateRef;
		public Integer TaxOrder;
		public String TaxTypeApplicable;
	}
	public class TaxCode{
		public PurchaseTaxRateList PurchaseTaxRateList;
		public Boolean sparse;
		public String Id;
		public String domain;
		public String SyncToken;
		public String TaxCodeConfigType;
		public SalesTaxRateList SalesTaxRateList;
		public Boolean Hidden;
		public Boolean Taxable;
		public Boolean Active;
		public Boolean TaxGroup;
		public String Description;
		public MetaData MetaData;
		public String Name;
	}
	public class SalesTaxRateList{
		public list<TaxRateDetail> TaxRateDetail;
	}
	public class QueryResponse{
		public Integer startPosition;
		public Integer maxResults;
		public list<TaxCode> TaxCode;
		public Integer totalCount;
	}
	public class PurchaseTaxRateList{
		public list<String> TaxRateDetail;
	}
	public class MetaData{
		public String CreateTime;
		public String LastUpdatedTime;
	}
	public static QBTaxRateJSON parse(String json){
		return (QBTaxRateJSON) System.JSON.deserialize(json, QBTaxRateJSON.class);
	}

}