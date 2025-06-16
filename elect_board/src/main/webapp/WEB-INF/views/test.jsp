<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
	<meta charset="UTF-8">
	<title>전력 사용량 예측</title>
	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
	<h2>단기 전력 사용량 예측</h2>
	<form id="shortForm">
		도시 코드: <input type="number" id="cityEncodedShort" required><br>
		연도: <input type="number" id="yearShort" required><br>
		월: <input type="number" id="monthShort" required><br>
		전년도 사용량: <input type="number" step="0.01" id="prevUsage" required><br>
		<button type="submit">단기 예측 요청</button>
	</form>
	<div id="shortResult" style="margin-top: 10px; font-weight: bold;"></div>

	<hr>

	<h2>장기 전력 사용량 예측</h2>
	<form id="longForm">
		도시 코드: <input type="number" id="cityEncodedLong" required><br>
		연도: <input type="number" id="yearLong" required><br>
		월: <input type="number" id="monthLong" required><br>
		<button type="submit">장기 예측 요청</button>
	</form>
	<div id="longResult" style="margin-top: 10px; font-weight: bold;"></div>

	<script>
	$(document).ready(function() {
		// 단기 예측 폼
		$('#shortForm').submit(function(e) {
			e.preventDefault();

			const data = {
			city_encoded: parseInt($('#cityEncodedShort').val()),
			year: parseInt($('#yearShort').val()),
			month: parseInt($('#monthShort').val()),
			prev_usage: parseFloat($('#prevUsage').val())
		};

		$.ajax({
			url: '/modelShort',
			method: 'POST',
			contentType: 'application/json',
			data: JSON.stringify(data),
			success: function(response) {
				$('#shortResult').text('단기 예측 결과: ' + response.prediction);
          },
			error: function(xhr, status, error) {
				$('#shortResult').text('오류 발생: ' + xhr.status + ' ' + error);
			}
		});
		});

		// 장기 예측 폼
		$('#longForm').submit(function(e) {
			e.preventDefault();

			const data = {
				city_encoded: parseInt($('#cityEncodedLong').val()),
				year: parseInt($('#yearLong').val()),
				month: parseInt($('#monthLong').val())
			};

			$.ajax({
				url: '/modelLong',
				method: 'POST',
				contentType: 'application/json',
				data: JSON.stringify(data),
				success: function(response) {
					$('#longResult').text('장기 예측 결과: ' + response.prediction);
				},
				error: function(xhr, status, error) {
					$('#longResult').text('오류 발생: ' + xhr.status + ' ' + error);
          		}
			});
		});
	});
  </script>
</body>
</html>
