/*
 * Copyright (c) 2012, Lawrence Livermore National Security, LLC. Produced at the Lawrence Livermore National Laboratory. Written by Kevin Lawrence <kevin_r_lawrence@yahoo.com>
 * LLNL-CODE-521811 All rights reserved. This file is part of IRIS 
 * Please also read the file LICENSE.txt  – Our Notice and GNU General Public License.
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (as published by the Free Software Foundation) version 2, dated June 1991.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the IMPLIED WARRANTY OF MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the terms and conditions of the GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

package test;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryPoolMXBean;
import java.lang.management.MemoryType;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;

import gov.llnl.iscr.iris.*;

import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;

import com.mongodb.BasicDBObject;
import com.mongodb.DBCursor;


public class MainTestDriver {
	LDAHandlerTest ldaHandlerTest;
	IrisTest irisTest;
	MongoInstance mongo;
	LDAModel model;
	LDAHandler ldaHandler;
	Iris iris;
	DisMaxQuery query;
	
	public MainTestDriver(){
		ldaHandlerTest = new LDAHandlerTest();
		irisTest = new IrisTest();
		mongo = new MongoInstance("127.0.0.1", "trecla");
		model = new LDAModel(mongo);
		ldaHandler = new LDAHandler(model);
		iris = new Iris(ldaHandler);
		query = new DisMaxQuery("environmental policy");
		
		iris.setLatentTopics(getResults(query));
		iris.setLatentTopicsNgrams();
	}
	public void testSetGetThreshold(float thresholdPercentile){
		ldaHandlerTest.threshold(ldaHandler, thresholdPercentile);
	}
	public void testSetGetEnrichedTopicSet(SolrDocumentList results){
		ldaHandlerTest.setEnrichedTopicSet(ldaHandler, results);
	}
	public void testSetGetRelatedTopicSet(SolrDocumentList results){
		ldaHandlerTest.setRelatedTopicSet(ldaHandler, results);
	}
	public void testSetGetNgrams(SolrDocumentList results){
		ldaHandlerTest.setNgrams(ldaHandler, results);
	}
	public void testExpandBoostQuery(){
		irisTest.expandBQ(iris, query, Arrays.asList("134"));
	}
	
	public void testExpandBoostQuery(String field){
		irisTest.expandBQ(iris, query, Arrays.asList("474", "391"), field);
	}
	public void testExpandBoostQuery(float boost){
		irisTest.expandBQ(iris, query, Arrays.asList("126"), boost);
	}
	public void testExpandBoostQuery(String field, float boost){
		irisTest.expandBQ(iris, query, Arrays.asList("68"), field, boost);
	}
	
	public void testResetBoostQuery(){
		irisTest.resetBQ(iris, query, Arrays.asList("81", "15"));
	}
	
	public void testResetBoostQuery(String field){
		irisTest.resetBQ(iris, query, Arrays.asList("298", "154"), field);
	}
	public void testResetBoostQuery(float boost){
		irisTest.resetBQ(iris, query, Arrays.asList("450"), boost);
	}
	public void testResetBoostQuery(String field, float boost){
		irisTest.resetBQ(iris, query, Arrays.asList("247", "436"), field, boost);
	}
	public void testCompleteSequence(){
		irisTest.completeSystemTest(iris, ldaHandler, new DisMaxQuery("environmental policy"));
	}
	public DisMaxQuery getQuery(){
		return query;
	}
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		MainTestDriver mainTestDriver = new MainTestDriver();
		
		long start, end, total;
		start = System.currentTimeMillis();
		
		//-|=========================================
		//-|Testing LDAHandler
		//-|=========================================
		
		//-|Testing set and get threshold for LDAHandler
		//float thresholdPercentile = 0.25F;
		//mainTestDriver.testSetGetThreshold(thresholdPercentile);
		
		//-|Testing set and get enriched set for LDAHandler
		//SolrDocumentList results = getResults(mainTestDriver.getQuery());
		//mainTestDriver.testSetGetEnrichedTopicSet(results);
		
		//-|Testing set and get related set for LDAHandler
		//mainTestDriver.testSetGetRelatedTopicSet(results);
		
		//-|Testing set and get ngrams and unigrams for LDAHandler
		//mainTestDriver.testSetGetNgrams(results);
		
		//-|=================
		//-|Testing Iris
		//-|=================
		
		//-|======================================
		//-|Testing Iris2 expandBoostQuery methods
		//-|======================================
		//mainTestDriver.testExpandBoostQuery();
		
		//String field = "text";
		//mainTestDriver.testExpandBoostQuery(field);
		
		//float boost = 5.0F;
		//mainTestDriver.testExpandBoostQuery(boost);
		//mainTestDriver.testExpandBoostQuery(field, boost);					
				
		//-|=============================================
		//-|Testing Iris resetBoostQuery methods
		//-|=============================================
		//mainTestDriver.testResetBoostQuery();
		//mainTestDriver.testResetBoostQuery(10.0F);
		//mainTestDriver.testResetBoostQuery(field);
		//mainTestDriver.testResetBoostQuery(field, 15.0F);
		
		//-|Testing complete sequence of events for iris
		mainTestDriver.testCompleteSequence();
		
		end = System.currentTimeMillis();
		total = end - start;
		System.out.println("Time taken: "+ total+" ms");
		
		for (MemoryPoolMXBean mpBean: ManagementFactory.getMemoryPoolMXBeans()) {
		    if (mpBean.getType() == MemoryType.HEAP) {
		        System.out.printf(
		            "Name: %s: %s\n",
		            mpBean.getName(), mpBean.getUsage()
		        );
		    }
		}

	}
	private static class LDAHandlerTest{
		public void threshold(LDAHandler ldaHandler, float thresholdPercentile){
			System.out.println("|==============================================\n" +
					"Testing set/get methods for LDAHandler topic threshold...\n" +
					"|==============================================");
			System.out.println("All topics and semco values (sorted descending): ");
			DBCursor cur = ldaHandler.getModel().getSemcoValues();
			while(cur.hasNext()){
				System.out.println(cur.next());
			}
			System.out.println("\n======Thresholding at "+(thresholdPercentile*100)+"% ...");
			ldaHandler.setTopicThreshold(thresholdPercentile);
			System.out.println("Topic Threshold: semco value "+ldaHandler.getTopicThreshold());
		}
		@SuppressWarnings("unchecked")
		public void setEnrichedTopicSet(LDAHandler ldaHandler, SolrDocumentList results){
			System.out.println("|==============================================\n" +
					"Testing set/get methods for LDAHandler Enriched Topic Set...\n" +
					"|==============================================\n");
			for(int i=0; i<2; i++){
				System.out.println("=====Topics for document "+(i+1)+": ");
				for(BasicDBObject topic: (List<BasicDBObject>)ldaHandler.getModel().getTopics(results.get(i).get("id")).get("topics")){
					System.out.println(topic);
				}
				System.out.println("=======END Document "+(i+1)+" topics========\n");
			}
			System.out.println("Threshold set to: "+ldaHandler.getTopicThreshold());
			System.out.println("Setting enriched topic set... ");
			ldaHandler.setEnrichedTopicSet(Arrays.asList(results.get(0).get("id"), results.get(1).get("id")));
			DBCursor cur = ldaHandler.getModel().getSemcoValues(ldaHandler.getEnrichedTopicSet());
			System.out.println("=====Enriched set: "+ldaHandler.getEnrichedTopicSet());
			while(cur.hasNext()){
				System.out.println(cur.next());
			}
		}
		public void setRelatedTopicSet(LDAHandler ldaHandler, SolrDocumentList results){
			System.out.println("|==============================================\n" +
					"Testing set/get methods for LDAHandler Related Topic Set...\n" +
					"|==============================================\n");
			System.out.println("Setting enriched topic set... ");
			ldaHandler.setEnrichedTopicSet(Arrays.asList(results.get(0).get("id"), results.get(1).get("id")));
			List<DBCursor> relatedTopics = ldaHandler.getModel().getRelatedTopics(ldaHandler.getEnrichedTopicSet());
			for(int i=0; i<relatedTopics.size(); i++){
				DBCursor cur = relatedTopics.get(i);
				System.out.println("=====Related Topics for document "+(i+1)+": ");
				while(cur.hasNext()){
					System.out.println(cur.next());
				}
				System.out.println("=======END Document "+(i+1)+" topics========\n");
			}
			System.out.println("Threshold set to: "+ldaHandler.getTopicThreshold());
			ldaHandler.setRelatedTopicSet();
			DBCursor cur = ldaHandler.getModel().getSemcoValues(ldaHandler.getRelatedTopicSet());
			System.out.println("=====Related set: "+ldaHandler.getRelatedTopicSet());
			while(cur.hasNext()){
				System.out.println(cur.next());
			}
		}
		public void setNgrams(LDAHandler ldaHandler, SolrDocumentList results){
			ldaHandler.setEnrichedTopicSet(Arrays.asList(results.get(0).get("id"), results.get(1).get("id")));
			System.out.println("Enriched set: "+ldaHandler.getEnrichedTopicSet());
			ldaHandler.setRelatedTopicSet();
			System.out.println("Related set: "+ldaHandler.getRelatedTopicSet());
			List<Object> topicIDs = new ArrayList<Object>(ldaHandler.getEnrichedTopicSet());
			topicIDs.addAll(ldaHandler.getRelatedTopicSet());
			System.out.println("All topics: "+topicIDs);
			Iterator<Object> it = topicIDs.iterator();
			Object o;
			while(it.hasNext()){
				o = it.next();
				System.out.println("===="+o+"====");
				System.out.println("ALL ngrams: "+ldaHandler.getModel().getNgrams(o));
				ldaHandler.setNgrams(o);
				System.out.println("SELECTED ngrams  : "+ldaHandler.getSelectedNgrams());
				//Eclipse console reacts strangely to printing out ALL unigrams; remove comment tag below to observe
				//System.out.println("\nALL unigrams: "+ldaHandler.getModel().getUnigrams(o));
				ldaHandler.setUnigrams(o);
				System.out.println("SELECTED unigrams: "+ldaHandler.getSelectedUnigrams());
				System.out.println(":***********:\n");
			}
		}
	}
	
	private static class IrisTest{
		public Iris expandBQ(Iris iris, DisMaxQuery query, List<String> bqTerms){
			System.out.println("Testing Iris expandBoostQuery(List<String> bqTerms)...");
			iris.expandBoostQuery(query, bqTerms, '+');
			System.out.println("Expanded Query: "+query+"\n");
			return iris;
		}
		public Iris expandBQ(Iris iris, DisMaxQuery query,  List<String> bqTerms, String field){
			System.out.println("Testing Iris expandBoostQuery(List<String> bqTerms, String field)...");
			iris.expandBoostQuery(query, bqTerms, field, '+');
			System.out.println("Expanded Query: "+query+"\n");
			return iris;
		}
		public Iris expandBQ(Iris iris, DisMaxQuery query,  List<String> bqTerms, float boost){
			System.out.println("Testing Iris expandBoostQuery(List<String> bqTerms, float boost)...");
			iris.expandBoostQuery(query, bqTerms, boost, '+');
			System.out.println("Expanded Query: "+query+"\n");
			return iris;
		}
		public Iris expandBQ(Iris iris, DisMaxQuery query,  List<String> bqTerms, String field, float boost){
			System.out.println("Testing Iris expandBoostQuery(List<String> bqTerms, String field, float boost)...");
			iris.expandBoostQuery(query, bqTerms, field, boost, '+');
			System.out.println("Expanded Query: "+query+"\n");
			return iris;
		}
		public Iris resetBQ(Iris iris, DisMaxQuery query,  List<String> bqTerms){
			System.out.println("Testing Iris resetBoostQuery(List<String> bqTerms)...");
			iris.resetBoostQuery(query, bqTerms);
			System.out.println("Expanded Query: "+query+"\n");
			return iris;
		}
		public Iris resetBQ(Iris iris, DisMaxQuery query,  List<String> bqTerms, String field){
			System.out.println("Testing Iris resetBoostQuery(List<String> bqTerms, String field)...");
			iris.resetBoostQuery(query, bqTerms, field);
			System.out.println("Expanded Query: "+query+"\n");
			return iris;
		}
		public Iris resetBQ(Iris iris, DisMaxQuery query,  List<String> bqTerms, float boost){
			System.out.println("Testing Iris resetBoostQuery(List<String> bqTerms, float boost)...");
			iris.resetBoostQuery(query, bqTerms, boost);
			System.out.println("Expanded Query: "+query+"\n");
			return iris;
		}
		public Iris resetBQ(Iris iris, DisMaxQuery query,  List<String> bqTerms, String field, float boost){
			System.out.println("Testing Iris resetBoostQuery(List<String> bqTerms, String field, float boost)...");
			iris.resetBoostQuery(query, bqTerms, field, boost);
			System.out.println("Expanded Query: "+query+"\n");
			return iris;
		}
		
		public void completeSystemTest(Iris iris, LDAHandler ldaHandler, DisMaxQuery query){
			printTopics(iris, getResults(query));
			
			iris.resetBoostQuery(query, Arrays.asList("298", "68"), 5.0F);
			System.out.println("*********Topics selected: 298 and 68***********");
			printTopics(iris, getResults(query));
			
		
		}
		
		private void printTopics(Iris iris, SolrDocumentList results){
			iris.setLatentTopics(results);
			iris.setLatentTopicsNgrams();
			
			Set<Entry<Integer, List<BasicDBObject>>> entrySet = iris.getLatentTopicNgrams().entrySet();
		
			System.out.println("\n==============Formatted topics and ngrams: ");
			for(Entry<Integer, List<BasicDBObject>> ngrams : entrySet){
				System.out.println("Topic: "+ngrams.getKey()+"\n"+iris.getTrigram(ngrams.getValue()));
				System.out.println(iris.getBigrams(ngrams.getValue()));
				System.out.println(iris.getUnigrams(ngrams.getValue())+"\n");
			}
			int i = 1;
			for(SolrDocument doc : results){
				System.out.println(i+")"+doc.get("title"));
				++i;
			}
			System.out.println(":==================END========================");
		}
	
	}
	
	public static SolrDocumentList getResults(DisMaxQuery query){
		SolrServer server = null;
		QueryResponse response = null;
		try {
			server = new CommonsHttpSolrServer("http://localhost:8983/solr/");
			
		} catch (MalformedURLException e) {
			e.printStackTrace();
		}
		
		try {
			response = server.query(query);
		} catch (SolrServerException e) {
			e.printStackTrace();
		}
		
		return response.getResults();
	}

}
