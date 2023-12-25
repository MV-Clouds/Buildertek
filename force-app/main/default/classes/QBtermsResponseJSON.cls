public with sharing class QBtermsResponseJSON {
    public QueryResponse QueryResponse;
    // public String time;

    public class Term{
        public String Id;
        public Boolean sparse;
        public String SyncToken;
        public String domain;
        public MetaData MetaData;
        public Double DueDays;
        public Boolean Active;
        public String Type;
        public String Name;
    }

    public class QueryResponse{
        public list<Term> Term;
        public Double maxResults;
        public Double startPosition;
    }

    public class MetaData{
        public String CreateTime;
        public String LastUpdatedTime;
    }

    public static QBtermsResponseJSON parse(String json) {
		System.debug('in parse ');
		return (QBtermsResponseJSON) System.JSON.deserialize(json, QBtermsResponseJSON.class);
	}
}