<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ShortModel</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/short.css" />
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
	$(document).ready(function(){
		let today = new Date();
	    let year = today.getFullYear();
	    let month = today.getMonth() + 1;
	    $("#month").html("<h2>"+month+"월 예상<br>전력 사용량</h2>");
	    
		
	    // 메뉴안에 예측값 넣기
	    $('.menu').not('#month').each(function() {
	        let $this = $(this);
	        predictAndReturn($this, year, month, function(error, prediction) {
	            if (error) {
	                $this.find('p').text(error); // '예측 오류' 또는 '전년도 데이터 오류'
	            } else {
	                $this.find('p').text(prediction + ' GWh'); // 정상값
	            }
	        });
	    });
	    
	 	// 전년도 사용량 조회 함수
	    function getPreviousUsage($element, year, month, callback) {
	        $.ajax({
	            url: '/getPrevUsage',
	            method: 'GET',
	            dataType: 'json',
	            data: {
	                region: $element.find('h2').text(),
	                year: year,
	                month: month
	            },
	            success: function(response) {
	                callback(null, response.usage); // 성공 시 usage 반환
	            },
	            error: function() {
	                callback('전년도 데이터 오류', null); // 에러 시
	            }
	        });
	    }
	 	
	 	// 전력량 예측 함수
	    function predictAndReturn($element, year, month, callback) {
	        let cityCode = $element.data('citycode');

	        if (cityCode !== undefined) {
	            getPreviousUsage($element, year, month, function(error, prevUsage) {
	                if (error) {
	                    callback(error);
	                    return;
	                }

	                $.ajax({
	                    url: '/modelShort',
	                    method: 'POST',
	                    contentType: 'application/json',
	                    data: JSON.stringify({
	                        city_encoded: cityCode,
	                        year: year,
	                        month: month,
	                        prev_usage: prevUsage
	                    }),
	                    success: function(predictionResponse) {
	                        let prediction = predictionResponse.prediction;
	                        callback(null, prediction);
	                    },
	                    error: function() {
	                        callback('예측 오류');
	                    }
	                });
	            });
	        } else {
	            callback('도시 코드 없음');
	        }
	    }

	});
</script>
</head>
<body>
<div id=box>
<div id="main">
<div id=mainLeft>
<div id="prevUsageBox">
<h2>전년도 대비 사용량</h2>
</div>
<div id="tMonthUsageBox">
<h2>최근 3개월 사용량</h2>
</div>
</div>
<div id="mainRight">
<div id="monthUsageBox">
<h1>서울 2025년 전력 사용량 분석</h1>
</div>
<div id="yearUsageBox">
<h2>최근 5년 6월 사용량</h2>
</div>
</div>
</div>
<div id="menu">
<div class="menu" id="seoul" data-citycode="8"><h2>서울</h2><p>0GWh</p></div>
<div class="menu" id="busan" data-citycode="7"><h2>부산</h2><p>0GWh</p></div>
<div class="menu" id="daegu" data-citycode="5"><h2>대구</h2><p>0GWh</p></div>
<div class="menu" id="incheon" data-citycode="11"><h2>인천</h2><p>0GWh</p></div>
<div class="menu" id="daejeon" data-citycode="6"><h2>대전</h2><p>0GWh</p></div>
<div class="menu" id="gwangju" data-citycode="4"><h2>광주</h2><p>0GWh</p></div>
<div class="menu" id="ulsan" data-citycode="10"><h2>울산</h2><p>0GWh</p></div>
<div class="menu" id="sejong" data-citycode="9"><h2>세종</h2><p>0GWh</p></div>
<div class="menu" id="jeju" data-citycode="14"><h2>제주도</h2><p>0GWh</p></div>
<div class="menu" id="gyeonggi" data-citycode="1"><h2>경기도</h2><p>0GWh</p></div>
<div class="menu" id="gyeongnam" data-citycode="2"><h2>경상남도</h2><p>0GWh</p></div>
<div class="menu" id="gyeongbuk" data-citycode="3"><h2>경상북도</h2><p>0GWh</p></div>
<div class="menu" id="chungnam" data-citycode="15"><h2>충청남도</h2><p>0GWh</p></div>
<div class="menu" id="month"></div>
<div class="menu" id="chungbuk" data-citycode="16"><h2>충청북도</h2><p>0GWh</p></div>
<div class="menu" id="jeonnam" data-citycode="12"><h2>전라남도</h2><p>0GWh</p></div>
<div class="menu" id="jeonbuk" data-citycode="13"><h2>전라북도</h2><p>0GWh</p></div>
<div class="menu" id="gangwon" data-citycode="0"><h2>강원도</h2><p>0GWh</p></div>
</div>
</div>
<h1 id="result"></h1>
</body>
</html>