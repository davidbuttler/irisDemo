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
<%@ page import="java.util.*, 
org.apache.solr.common.SolrDocumentList, 
org.apache.solr.common.SolrDocument" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
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
					Date d = new Date();
					%>
					<p class="meta"><small><%= d.toString() %></small></p>
					<div class="entry">
						<form name="userinput" method="get" action="index.jsp">
							<fieldset>
							<input type="text" name="userquery" class=searchbox></input>
							<input type="submit" name="search" value="Submit" class=searchbutton ></input>
							</fieldset>
						</form>
					</div>
				</div>
				<div class="result">
					<%
					SolrDocumentList rsltList = (SolrDocumentList) session.getAttribute("ResultSet");
					String text ="";
					String title = "";
					if(rsltList != null){
						if(rsltList.size() != 0){
							SolrDocument rsltDoc = rsltList.get(Integer.parseInt(request.getParameter("index")));
							text = rsltDoc.getFieldValue("text").toString();
							title = rsltDoc.getFieldValue("title").toString();
						}	
					}
					out.println("<h2 class=\"title\">"+title+"</h2>");
					out.println("<div class=\"desc\">");
					out.println("<p>"+text+"</p>");
					out.println("</div>");
					%>
				</div>
			</div>
			<!-- end content -->
			<!-- start sidebar -->
			<div id="sidebar">
				<ul>
					<li id="categories">
						<h2>Document Info (Summary)</h2>
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
