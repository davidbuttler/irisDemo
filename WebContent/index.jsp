<?xml version="1.0" encoding="UTF-8" ?>
<!--

Copyright (c) 2012, Lawrence Livermore National Security, LLC. Produced at the Lawrence Livermore National Laboratory. Written by Kevin Lawrence (kevin_r_lawrence@yahoo.com)
 LLNL-CODE-521811 All rights reserved. This file is part of IRIS
 Please also read the file LICENSE.txt  – Our Notice and GNU General Public License.
 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (as published by the Free Software Foundation) version 2, dated June 1991.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the IMPLIED WARRANTY OF MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the terms and conditions of the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 -->

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.net.MalformedURLException, gov.llnl.iscr.iris.*, 
com.mongodb.BasicDBObject, org.apache.solr.client.solrj.SolrServer, org.apache.solr.client.solrj.impl.CommonsHttpSolrServer, org.apache.solr.common.SolrDocumentList, 
org.apache.solr.client.solrj.response.QueryResponse, org.apache.solr.common.SolrDocument, java.util.Map.Entry, 
java.lang.management.ManagementFactory, java.lang.management.MemoryPoolMXBean, java.lang.management.MemoryType" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<%!
	public int toInt(Object obj)
	{   
			int conv=0;
			if(obj==null)
			{
				obj="0";
			}
			else if(obj.equals(""))
				obj = "0";
			try{
				conv=Integer.parseInt(obj.toString());
			}
			catch(Exception e)
			{
			}
			return conv;
	}
%>
<%!
	public SolrServer getSolr(String url, SolrServer solr){
		if(solr == null){
			try {
				solr = new CommonsHttpSolrServer(url);
				
			} catch (MalformedURLException e) {
				e.printStackTrace();
			}
		}
		return solr;
	}
%>
<%!
	public DisMaxQuery setupQuery(DisMaxQuery disMaxQuery){
		if(disMaxQuery != null){
			disMaxQuery.setDefaultBoost(5.0F);	
			disMaxQuery.setHighlights(2, "text");
		}
		
		return disMaxQuery;
	}
%>
<%! public String getUserQuery(HttpServletRequest request){
		String uq = "";
		if(request.getParameter("userquery") != null)
			uq = request.getParameter("userquery");
						
		return uq;
	}
%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>IRIS</title>
<meta name="keywords" content="" />
<meta name="description" content="" />
<link href="default.css" rel="stylesheet" type="text/css" />
</head>
<body>
<div id="wrapper">
	<div id="wrapper-bgtop">
		<!-- start header -->
		<div id="header">
			<div id="logo">
				<h1><a href="#">IRIS </a></h1>
				<p><a href="files/project.pdf">Enhancing Text Navigation<br/> with<br/> Latent Topic Feedback</a></p>
			</div>
			<div id="menu">
				<ul>
					<li class="active"><a href="index.jsp">Home</a></li>
					<li><a href="#">About</a></li>
					<li><a href="#">Logs</a></li>
					<li><a href="#">Contact </a></li>
				</ul>
			</div>
		</div>
		<hr />
		<!-- end header -->
		<!-- start page -->
		<div id="page">
			<!-- start content -->
			<div id="content">
				<div class="post">
					<h2 class="title">Demo Web Interface</h2>
					<%
						//-|=================================
						//-|Checking initial time
						//-|=================================
						long start, end, total;
						start = System.currentTimeMillis();
						//-|=========END time check==========
								
						Date d = new Date();
								
								//-|============================================================
								//-|PAGINATION SET UP
								//-|	Controls paging of results
								//-|============================================================
								final double rowsPerPage=10.0;  // Number of records displayed per page
								final int numOfPagesDisplayed=10;  // Number of pages index displayed
								
								int startPageNo = toInt(session.getAttribute("startPageNo"));
								int prePageNo=toInt(request.getParameter("prevPg"));
								int nextPageNo=toInt(request.getParameter("nxtPg"));
								if(startPageNo ==0){
									startPageNo = 1;
									session.setAttribute("startPageNo", startPageNo);
								}
								if(prePageNo >0){
									if(prePageNo<startPageNo){
										startPageNo=prePageNo;
										session.setAttribute("startPageNo", startPageNo);
									}
								}
								int endPageNo= (startPageNo-1)+numOfPagesDisplayed;
								if(nextPageNo>endPageNo){
									session.setAttribute("startPageNo", ++startPageNo);
								}
								int indexPageNo=toInt(request.getParameter("page"));
								if(indexPageNo==0){
									indexPageNo=1;
								}
								int totalPages =toInt(session.getAttribute("totalPages"));
								int startResultNo= (indexPageNo-1)*(int)rowsPerPage;	    
								
								//-|=======================================
								//-|Setting up Iris components
								//-|======================================
								Iris iris;
								SolrServer solr = getSolr("http://localhost:8983/solr/", (SolrServer)session.getAttribute("server"));
								session.setAttribute("server", solr);
								if(session.getAttribute("iris") == null){
									final MongoInstance mongo = new MongoInstance("127.0.0.1", "trecla");
									final LDAModel model = new LDAModel(mongo);
									final LDAHandler ldaHandler = new LDAHandler(model);
									iris = new Iris(ldaHandler);
									session.setAttribute("iris", iris);
									
								}else{
									iris = (Iris) session.getAttribute("iris");
								}
								
								//-|===============================================================================
								//-|Setting up variables neccessary for page
								//-|  inlcuding: 	The user query (retrieved from the request)
								//-|				The search type ie. is it a new, expanded or reset query search
								//-|				The topic selections (if any)
								//-|				The disMaxQuery (maintained in a session variable)
								//-|===============================================================================
								String searchType = request.getParameter("search");
								String userQuery = getUserQuery(request);
								
								@SuppressWarnings("unchecked")
								List<String> topicSelections = (ArrayList<String>)session.getAttribute("topicSelections");//keeps track of selections made
								List<String> posTopicSelection = new ArrayList<String>(); //store positive topics selections per request
								List<String> negTopicSelection = new ArrayList<String>();//store negative topics selections per request
								
								DisMaxQuery disMaxQuery = (DisMaxQuery) session.getAttribute("dismaxquery");
								
								//-|=========================================================================
								//-|Differentiation of search type; necessary to properly build dismaxquery
								//-|New search - new dismaxquery
								//-|Modify search - expansion of exisiting dismaxquery using boostquery
								//-|	
								//-|=========================================================================
								if(searchType != null){
									if(searchType.equalsIgnoreCase("submit")){
										//New search
										startPageNo = 1;
										session.setAttribute("startPageNo", startPageNo);
										
										if(userQuery != null){
											disMaxQuery = new DisMaxQuery(userQuery);
											setupQuery(disMaxQuery);
											session.setAttribute("dismaxquery", disMaxQuery);
										}
										session.setAttribute("topicSelections", new ArrayList<String>());
									}
									else if (searchType.equalsIgnoreCase("reset") || searchType.equalsIgnoreCase("expand")){
										//Modify search
										startPageNo = 1;
										session.setAttribute("startPageNo", startPageNo);
										
										//Getting parameter names to extract Topic IDs
										Enumeration<String> e = request.getParameterNames();
										while(e.hasMoreElements()){
											String s = e.nextElement();
											if(s.startsWith("TopicLabel"))
												posTopicSelection.add(request.getParameter(s));
										}
										//Keep track of all topics selected to prevent 
										//positive and negative boosting on the same topic
										
										if(!posTopicSelection.isEmpty()){
											//Retrieving topics selected for negative boosting
											List<String> toRemove = new ArrayList<String>();
											for(int i=0; i< posTopicSelection.size(); i++){
												String topicID = posTopicSelection.get(i);
												if(topicID.startsWith("-")){
													toRemove.add(topicID);
													topicID = topicID.substring(1);
													negTopicSelection.add(topicID);
												}
														
											}									
											//Remove negative boosted topics from postive boosted topic selections
											if(!toRemove.isEmpty()){
												posTopicSelection.removeAll(toRemove);
											}
											
											//Reset or Expand?
											if(searchType.equalsIgnoreCase("reset")){
												if(!posTopicSelection.isEmpty()){
													topicSelections = new ArrayList<String>(posTopicSelection);
													iris.resetBoostQuery(disMaxQuery, posTopicSelection);
													if(!negTopicSelection.isEmpty()){
														iris.expandBoostQuery(disMaxQuery, negTopicSelection, 10000F, '-');
														topicSelections.addAll(negTopicSelection);
													}
														
												}
											}else if(searchType.equalsIgnoreCase("expand")){
												if(!posTopicSelection.isEmpty()){
													posTopicSelection.removeAll(topicSelections);
													iris.expandBoostQuery(disMaxQuery, posTopicSelection, '+');
													
													topicSelections.addAll(posTopicSelection);
												}
												if(!disMaxQuery.getBoostQuery().isEmpty()){
													if(!negTopicSelection.isEmpty()){												
														negTopicSelection.removeAll(topicSelections);
														iris.expandBoostQuery(disMaxQuery, negTopicSelection, 10000F, '-');
														
														topicSelections.addAll(negTopicSelection);
													}	
												}
											}
											session.setAttribute("topicSelections", topicSelections);	
											session.setAttribute("dismaxquery", disMaxQuery);
										}
										
									}
									
								}
					%>	
					<p class="meta"><small><%= d.toString() %></small></p>
					<div class="entry">
						<form name="userinput" method="get" action=<%= request.getRequestURI() %>>
							<fieldset>
							<%out.println("<input type=\"text\" name=\"userquery\" class=searchbox value=\""+userQuery+"\" ></input>"); %>
							<input type="submit" name="search" value="Submit" class=searchbutton ></input>
							</fieldset>
						</form>
						<% //GET RESULTS
						SolrDocumentList results = null;
						QueryResponse queryResponse = null;
						if(disMaxQuery != null){
							if(!disMaxQuery.getQuery().equals("")){
								disMaxQuery.setStart(startResultNo);
								queryResponse = solr.query(disMaxQuery);
								results = queryResponse.getResults();
								out.print("<p>executed query, results size = "+results.size()+" total retrieved = "+results.getNumFound()+"</p>");
							}
						}
						
						out.print("<p>"+disMaxQuery+"</p>");
						%>
					</div>
				</div>
				<div class="result">
					<% //PRINT RESULTS
					if(results != null){
						if(results.size() != 0){
							//out.print("<p>I'm about to print the results...</p>");
							long numFound = results.getNumFound();
							totalPages = (int) Math.ceil(numFound/rowsPerPage);
							session.setAttribute("totalPages", totalPages);
							String title;
							for(int i=0; i<results.size(); i++){
								SolrDocument rsltDoc = results.get(i);
								String id = (String) rsltDoc.getFieldValue("id");
								List<String> highlightSnippets = queryResponse.getHighlighting().get(id).get("text");
								title = rsltDoc.getFieldValue("title").toString();
								out.println("<h2 class=\"title\"><a href=\"resultText.jsp?docid="+id+"&index="+i+"\">"+title+"</a></h2>");
								out.println("<p class=\"meta\"><small>Author: <a href=\"#\">AuthorName</a> | Institution: <a href=\"#\">Affiliations</a> | Publication <a href=\"#\">Published By</a> | Date: Publication date | <a href=\"#\">Abstract &raquo;</a></small></p>");
								out.println("<div class=\"desc\">");
								out.println("<p>"+highlightSnippets+"</p>");
								out.println("</div>");
							}
						}
						else{
							out.println("<div class=\"desc\">");
							out.println("<p>Your search - <strong>"+userQuery+"</strong> - did not match any documents</p>");
							out.println("<ul>Suggestions:");
							out.println("<p></p>");
							out.println("<li>Make sure all words are spelled correctly</li>");
							out.println("<li>Try different keywords</li>");
							out.println("<li>try more general keywords</li>");
							out.println("</ul>");
							out.println("</div>");
						}
							
					}
					
					%>
				</div>
				<div class="pagination">
					<form name="paginationform">
					<ul id="pagination-digg">
					<% //PAGINATION
					if(results != null){
						if(!results.isEmpty()){
							
							
							if(indexPageNo==1){
								out.println("<li class=\"previous-off\">«Previous</li>");
							}
							else{
								prePageNo=indexPageNo-1;
								out.println("<li class=\"previous\"><a href=\"?userquery="+userQuery+"&page="+prePageNo+"&prevPg="+prePageNo+"\">«Previous</a></li>");
							}
							if(totalPages <= 10){
								for(int i=startPageNo; i<(totalPages+startPageNo); i++){
									if(i==indexPageNo)
										out.println("<li class=\"active\">"+i+"</li>");
									else
										out.println("<li><a href=\"?userquery="+userQuery+"&page="+i+"\">"+i+"</a></li>");
								}
							}else{
								for(int i=startPageNo; i<(numOfPagesDisplayed+startPageNo); i++){
									if(i==indexPageNo)
										out.println("<li class=\"active\">"+i+"</li>");
									else
										out.println("<li><a href=\"?userquery="+userQuery+"&page="+i+"\">"+i+"</a></li>");
								}
							}
							
							if(indexPageNo == totalPages){
								out.println("<li class=\"next-off\">Next »</li>");
							}
							else{
								nextPageNo=indexPageNo+1;
								out.println("<li class=\"next\"><a href=\"?userquery="+userQuery+"&page="+nextPageNo+"&nxtPg="+nextPageNo+"\">Next »</a></li>");
							}
						}
					}
					%>
					</ul>
					</form>
				</div>
			</div>
			<!-- end content -->
			<!-- start sidebar -->
			<div id="sidebar">
				<ul>
					<li id="categories">
						<h2>Topics</h2>
						<form name="expandinput" method="get" action="<%= request.getRequestURI() %>">
						<% //DISPLAY TOPICS AND ASSOCIATED NGRAMS
						if(results != null){
							if(!results.isEmpty()){
										out.println("<input type=\"hidden\" name=\"userquery\" value=\""+userQuery+"\">");
										out.println("<input type=\"submit\" name=\"search\" value=\"Expand\"></input>");
										out.println("<input type=\"submit\" name=\"search\" value=\"Reset\"></input>");
										out.println("<p></p>");
										out.println("<fieldset style=\"border:2px solid\">");
										out.println("<legend>Legend</legend>");
										out.println("<div>");
										out.println("<ul>");
										out.println("<p style=\"color:#33CC00\">&nbsp;&nbsp;&nbsp;<input type=\"radio\" style=\"background-color:#33CC00\" DISABLED/> - Positive (INCLUDE)</p>");
										out.println("<p style=\"color:#FF0000\">&nbsp;&nbsp;&nbsp;<input type=\"radio\" style=\"background-color:#FF0000\" DISABLED/> - Negative (EXCLUDE)</p>");
										out.println("</ul>");
										out.println("</div>");
										out.println("</fieldset>");
										out.println("<p></p>");
										
										//Display topics and ngrams
										iris.setLatentTopics(results);
										iris.setLatentTopicsNgrams();
										Map<Integer, List<BasicDBObject>> ngrams = iris.getLatentTopicNgrams();
							
										int i=0;
										for(Integer topicID : iris.getLatentTopics()){
											
											out.println("<ul>");
											out.println("<lh><label><input type=\"radio\" name=\"TopicLabel"+i+"\" value=\""+topicID
													+"\" style=\"background-color:#33CC00\"/>&nbsp;&nbsp;&nbsp;"
													+"<input type=\"radio\" name=\"TopicLabel"+i+"\" value=\"-"+topicID
													+"\" style=\"background-color:#FF0000\"/> Topic: "+topicID+"</label></lh>");
											out.println("<li>"+iris.getTrigram(ngrams.get(topicID))+"</li>");
											out.println("<li>"+iris.getBigrams(ngrams.get(topicID))+"</li>");
											out.println("<li>"+iris.getUnigrams(ngrams.get(topicID))+"</li>");
											out.println("</ul>");
											i++;
										}
										
										session.setAttribute("ResultSet", results);
								}
							}
							//-|=================================
							//-|Checking final time
							//-|=================================
							end = System.currentTimeMillis();
							total = end - start;
							System.out.println("Time taken: "+ total+" ms");
							//-|=========END time check==========
							for (MemoryPoolMXBean mpBean: ManagementFactory.getMemoryPoolMXBeans()) {
		    					if (mpBean.getType() == MemoryType.HEAP) {
		        					System.out.printf(
		            					"Name: %s: %s\n",
		            					mpBean.getName(), mpBean.getUsage()
		   							);
		    					}
							}
						%>
						</form>
					</li>
					<li>
						<h2>Suggestions</h2>
						<ul>
							<li><a href="#">Possibly list <strong>topics</strong> or</a></li>
							<li><a href="#"><strong>document titles</strong> viewed by other user</a></li>
							<li><a href="#">that executed a similar query</a></li>
							<li><a href="#">OR list documents viewed by other user</a></li>
							<li><a href="#">that explored similar topics.</a></li>
						</ul>
					</li>
					<li>
						<h2>Search Tools</h2>
						<ul>
							<li><a href="#">Browse Topics</a></li>
							<li><a href="#">Related Searches</a></li>
							<li><a href="#">Timeline</a></li>
						</ul>
					</li>
				</ul>
			</div>
			<!-- end sidebar -->
			<br style="clear: both;" />
		</div>
		<!-- end page -->
		<!-- start footer -->
		<div id="footer">
			<p id="legal"> &copy;2011 Butterfly . All Rights Reserved.
				&nbsp;&nbsp;&bull;&nbsp;&nbsp;
				Design by <a href="http://www.freecsstemplates.org/">Free CSS Templates</a> &nbsp;&nbsp;&bull;&nbsp;&nbsp;
				Icons by <a href="http://famfamfam.com/">FAMFAMFAM</a>. <a href="http://validator.w3.org/check/referer" class="xhtml" title="This page validates as XHTML">Valid <abbr title="eXtensible HyperText Markup Language">XHTML</abbr></a> &nbsp;&nbsp;&bull;&nbsp;&nbsp; <a href="http://jigsaw.w3.org/css-validator/check/referer" class="css" title="This page validates as CSS">Valid <abbr title="Cascading Style Sheets">CSS</abbr></a> </p>
			<!-- end footer -->
		</div>
	</div>
</div>
</body>
</html>
