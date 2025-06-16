<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>전력 사용량 예측</title>
</head>
<body>

<h2>단기 예측</h2>
<form action="/modelShort" method="post">
    도시 코드: <input type="text" name="cityEncoded"><br>
    연도: <input type="text" name="year"><br>
    월: <input type="text" name="month"><br>
    전년도 사용량: <input type="text" name="prevUsage"><br>
    <input type="submit" value="단기 예측 요청">
</form>

<h2>장기 예측</h2>
<form action="/modelLong" method="post">
    도시 코드: <input type="text" name="cityEncoded"><br>
    연도: <input type="text" name="year"><br>
    월: <input type="text" name="month"><br>
    <input type="submit" value="장기 예측 요청">
</form>

<% 
    String shortResult = (String) request.getAttribute("shortResult");
    String longResult = (String) request.getAttribute("longResult");
%>

<% if (shortResult != null) { %>
    <h3>단기 예측 결과:</h3>
    <p><%= shortResult %></p>
<% } %>

<% if (longResult != null) { %>
    <h3>장기 예측 결과:</h3>
    <p><%= longResult %></p>
<% } %>

</body>
</html>
