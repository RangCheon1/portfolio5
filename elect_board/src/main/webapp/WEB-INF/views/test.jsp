<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
    <meta charset="UTF-8">
    <title>전력 사용량 예측</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
<label for="predictionType">예측 타입 선택: </label>
<select id="predictionType">
    <option value="short">단기 예측</option>
    <option value="long">장기 예측</option>
</select>
<canvas id="monthlyChart" width="600" height="400"></canvas>
    <h2>단기 전력 사용량 예측</h2>
    <form id="shortForm">
        도시명: <input type="text" id="regionShort" required><br>
        연도: <input type="number" id="yearShort" required><br>
        월: <input type="number" id="monthShort" required><br>
        <button type="submit">단기 예측 요청</button>
    </form>
    <div id="shortResult" style="margin-top: 10px; font-weight: bold;"></div>

    <hr>

	<h2>장기 전력 사용량 예측</h2>
	<form id="longForm">
	    도시명: <input type="text" id="regionLong" required><br>
	    연도: <input type="number" id="yearLong" required><br>
	    월: <input type="number" id="monthLong" required><br>
	    <button type="submit">장기 예측 요청</button>
	</form>
	<div id="longResult" style="margin-top: 10px; font-weight: bold;"></div>

<script>
// 도시명 → 코드
const cityCodeMap = {
    "강원도": 0,
    "경기도": 1,
    "경상남도": 2,
    "경상북도": 3,
    "광주": 4,
    "대구": 5,
    "대전": 6,
    "부산": 7,
    "서울": 8,
    "세종": 9,
    "울산": 10,
    "인천": 11,
    "전라남도": 12,
    "전라북도": 13,
    "제주": 14,
    "충청남도": 15,
    "충청북도": 16
};

$(document).ready(function() {
	function renderChart(predictions, label) {
        const ctx = document.getElementById('monthlyChart').getContext('2d');
        const months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];

        if (window.monthlyBarChart) {
            window.monthlyBarChart.destroy();
        }

        window.monthlyBarChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: months,
                datasets: [{
                    label: label,
                    data: predictions,
                    backgroundColor: 'rgba(54, 162, 235, 0.6)',
                    borderColor: 'rgba(54, 162, 235, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }

    // 페이지 로드 시 바로 호출
    fetchMonthlyPredictions();
    
    // 단기 예측 그래프
    function fetchMonthlyPredictions() {
        const region = "강원도";
        const year = 2025;

        const cityEncoded = cityCodeMap[region];

        if (cityEncoded === undefined) {
            alert('알 수 없는 도시명입니다.');
            return;
        }

        let predictions = new Array(12).fill(null);
        let completedRequests = 0;

        for(let month = 1; month <= 12; month++) {
            $.ajax({
                url: '/getPrevUsage',
                method: 'GET',
                dataType: 'json',
                data: { region: region, year: year, month: month },
                success: function(prevUsage) {
                    const usage = prevUsage.usage;

                    if (!usage || usage === 0) {
                        predictions[month - 1] = null;
                        checkCompletion();
                        return;
                    }

                    const data = {
                        city_encoded: cityEncoded,
                        year: year,
                        month: month,
                        prev_usage: usage
                    };

                    $.ajax({
                        url: '/modelShort',
                        method: 'POST',
                        contentType: 'application/json',
                        data: JSON.stringify(data),
                        success: function(response) {
                            predictions[month - 1] = response.prediction;
                            checkCompletion();
                        },
                        error: function() {
                            predictions[month - 1] = null;
                            checkCompletion();
                        }
                    });
                },
                error: function() {
                    predictions[month - 1] = null;
                    checkCompletion();
                }
            });
        }

        function checkCompletion() {
            completedRequests++;
            if (completedRequests === 12) {
                renderChart(predictions, "2025년 월별 단기 전력 사용량 예측");
            }
        }
    }

    
    
 	
    //장기 예측 그래프
    function fetchMonthlyLongPredictions() {
        const region = "강원도";
        const year = 2025;

        const cityEncoded = cityCodeMap[region];

        if (cityEncoded === undefined) {
            alert('알 수 없는 도시명입니다.');
            return;
        }

        let predictions = new Array(12).fill(null);
        let completedRequests = 0;

        for(let month = 1; month <= 12; month++) {
            const data = {
                city_encoded: cityEncoded,
                year: year,
                month: month
            };

            $.ajax({
                url: '/modelLong',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(data),
                success: function(response) {
                    predictions[month - 1] = response.prediction;
                    checkCompletion();
                },
                error: function() {
                    predictions[month - 1] = null;
                    checkCompletion();
                }
            });
        }

        function checkCompletion() {
            completedRequests++;
            if (completedRequests === 12) {
                renderChart(predictions, "2025년 월별 장기 전력 사용량 예측");
            }
        }
    }

    $('#predictionType').change(function() {
        const selected = $(this).val();

        if (selected === 'short') {
            fetchMonthlyPredictions();
        } else if (selected === 'long') {
            fetchMonthlyLongPredictions();
        }
    });
}); 

//단기 예측 폼
/*  $('#shortForm').submit(function(e) {
     e.preventDefault();

     const region = $('#regionShort').val().trim();
     const year = parseInt($('#yearShort').val());
     const month = parseInt($('#monthShort').val());

     // 도시명으로 코드 찾기
     const cityEncoded = cityCodeMap[region];
     if (cityEncoded === undefined) {
         $('#shortResult').text('알 수 없는 도시명입니다.');
         return;
     }

     // 전년도 사용량 조회
     $.ajax({
         url: '/getPrevUsage',
         method: 'GET',
         dataType: 'json',
         data: {
             region: region,
             year: year,
             month: month
         },
         success: function(prevUsage) {
             const usage = prevUsage.usage;  // 사용량만 추출
             
             // 전년도 사용량이 없을시 조회 불가
			    if (usage === null || usage === undefined || usage === 0) {
			        $('#shortResult').text('2026년 3월까지만 조회가 가능합니다.');
			        return;  // 예측 요청 중단
			    }
             
             const data = {
                 city_encoded: cityEncoded,
                 year: year,
                 month: month,
                 prev_usage: usage
             };

             console.log("단기 예측 POST 전송 데이터:", data);

             $.ajax({
                 url: '/modelShort',
                 method: 'POST',
                 contentType: 'application/json',
                 data: JSON.stringify(data),
                 success: function(response) {
                     $('#shortResult').text('단기 예측 결과: ' + response.prediction);
                 },
                 error: function(xhr, status, error) {
                     $('#shortResult').text('FastAPI 호출 오류: ' + xhr.status + ' ' + error);
                 }
             });
         },
         error: function(xhr, status, error) {
             $('#shortResult').text('전년도 사용량 조회 오류: ' + xhr.status + ' ' + error);
         }
     });
 }); */
 

// 장기 예측 폼
/*  $('#longForm').submit(function(e) {
    e.preventDefault();

    const region = $('#regionLong').val().trim();
    const year = parseInt($('#yearLong').val());
    const month = parseInt($('#monthLong').val());

    // 도시명으로 코드 찾기
    const cityEncoded = cityCodeMap[region];
    if (cityEncoded === undefined) {
        $('#longResult').text('알 수 없는 도시명입니다.');
        return;
    }

    const data = {
        city_encoded: cityEncoded,
        year: year,
        month: month
    };

    console.log("장기 예측 POST 전송 데이터:", data);

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
});*/

</script>
</body>
</html>
