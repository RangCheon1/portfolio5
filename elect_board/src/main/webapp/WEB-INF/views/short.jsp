<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ShortModel</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/short.css" />
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.1/dist/chart.min.js"></script>
<script>
	$(document).ready(function(){
		let today = new Date();
	    let year = today.getFullYear();
	    let month = today.getMonth() + 1;
	    let nowMonthAll = 0.00;
	    $("#month").html("<h2>"+month+"월 예상<br>전력 사용량</h2>");
	    let prevAllUsage; // 전년도 1~12월 값
	    let yearAllUsage; // 올해 1~12월 값
	    let month4Years // 이번달 4년치 값
	    let Chart1 = null; // 차트1
	    let Chart2 = null; // 차트2
	    let Chart3 = null; // 차트3
	    let Chart4 = null; // 차트4
	    let Chart5 = null; // 차트5
	    let region = "서울";
	    
		
	 	// 메뉴 안에 예측값 넣기
	    async function setPredictionToMenu() {
	        const menus = $('.menu').not('#month'); // '전체' 제외

	        for (let i = 0; i < menus.length; i++) {
	            const $this = $(menus[i]);
	            try {
	                const prediction = await predictAndReturnCorrect($this, year, month);
	                $this.find('p').text(prediction + ' GWh');
	                nowMonthAll = nowMonthAll + prediction;
	            } catch (error) {
	                $this.find('p').text(error); // '예측 오류' 또는 '도시코드 없음'
	            }
	        }
	    }

	    // 호출
	    setPredictionToMenu();
	    
	 	// 전력 사용량 조회 함수
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
	                callback('데이터 오류', null); // 에러 시
	            }
	        });
	    }
	    function getPreviousUsagePromise($element, year, month) {
	        return new Promise((resolve, reject) => {
	            getPreviousUsage($element, year, month, (err, usage) => {
	                if (err) {
	                    reject(err);
	                } else {
	                    resolve(usage);
	                }
	            });
	        });
	    }
	 	
		// 4년치 월 데이터 가져오기 (예: 2021~2024)
	    async function getPast4YearsJuneUsage($element, thisYear) {
	        const promises = [];

	        for (let i = 4; i >= 1; i--) {
	            const yearToFetch = thisYear - i; // 4년 전부터 1년 전까지
	            promises.push(getPreviousUsagePromise($element, yearToFetch, month));
	        }

	        try {
	            const usageArray = await Promise.all(promises);
	            return usageArray;
	        } catch (err) {
	            console.error("4년치 "+month+"월 사용량 조회 실패:", err);
	            return [];
	        }
	    }
	 	
	 	// 전력 사용량 조회 함수(1월 ~ 12월)
		function getPrevAllUsagePromise($element, year) {
		    return new Promise((resolve, reject) => {
		        $.ajax({
		            url: '/getPrevAllUsage',
		            method: 'GET',
		            dataType: 'json',
		            data: { region: $element.find('h2').text(), year: year },
		            success: function(response) {
		                resolve(response.usage);
		            },
		            error: function() {
		                reject('전년도 데이터 오류');
		            }
		        });
		    });
		}
	 	
	 	
		// 단기 예측 Promise 버전 (전년도 사용량도 Promise로 처리)
		async function predictAndReturnCorrect($element, year, month) {
		    const cityCode = $element.data('citycode');
		    if (cityCode === undefined) throw '도시코드 없음';

		    try {
		        const prevUsage = await getPreviousUsagePromise($element, year - 1, month); // 전년도 값
		        const prediction = await $.ajax({
		            url: '/modelShort',
		            method: 'POST',
		            contentType: 'application/json',
		            data: JSON.stringify({
		                city_encoded: cityCode,
		                year: year-2014,
		                month: month,
		                prev_usage: prevUsage
		            })
		        });
		        return prediction.prediction; // FastAPI 서버가 {"prediction": XXX} 반환하니까
		    } catch (err) {
		        throw err; // 호출한 곳에서 catch 가능
		    }
		}
	 	
	 	// 메뉴 클릭 이벤트
		$(".menu").not("#month").on("click", async function() {
		    let $element = $(this);
		    let prevAllUsage;
		    let yearAllUsage;
		    let month4Years
		    let monthCount = 6; // chart2 개월수 지정
		    let sMonthLabels = [];
		    let sMonthData = [];
		    region = $(this).find('h2').text();
		    
		    console.log($(this).find('h2').text()+"ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
		    // 전년도 1월 ~ 12월 데이터 가져오기
		    try {
		        prevAllUsage = await getPrevAllUsagePromise($element, year-1);
		        console.log("전년도 사용량:", prevAllUsage);
		    } catch(err) {
		        console.error(err);
		    }
		    
		    // 올해 1월 ~ 12월 데이터 가져오기
		    try {
		        yearAllUsage = await getPrevAllUsagePromise($element, year);
		        console.log("이번년도 사용량(원본):", yearAllUsage);
		    } catch(err) {
		        console.error(err);
		    }
		    
		    // 0 또는 null이면 예측 모델 사용
		    for (let i = 0; i < 12; i++) {
		        if (!yearAllUsage[i] || yearAllUsage[i] === 0) {
		            try {
		                const predicted = await predictAndReturnCorrect($element, year, i + 1);
		                yearAllUsage[i] = predicted;
		            } catch (err) {
		                console.error(err);
		            }
		        }
		    }
		    console.log("이번년도 사용량(완성본):", yearAllUsage)
		    
		    // 4년치 월 사용량 가져오기
		    month4Years = await getPast4YearsJuneUsage($element, year);
		    console.log("4년치"+month+"월 사용량:", month4Years);
		    
		    // char2 라벨
			for (let i = monthCount - 1; i >= 0; i--) {
			    let targetMonth = month - i;
			    if (targetMonth <= 0) {
			        targetMonth += 12;
			    }
			    sMonthLabels.push(targetMonth + '월');
			}
		    
		    // chart2 데이터
		    for (let i = monthCount - 1; i >= 0; i--) {
		        let targetMonth = month - i; // 확인할 달
		        if (targetMonth <= 0) {
		            // 전년도 데이터 사용
		            sMonthData.push(prevAllUsage[12 + targetMonth - 1]); // 예: month = 3, i=5면 targetMonth = -2 → prevAllUsage[9]
		        } else {
		            // 올해 데이터 사용
		            sMonthData.push(yearAllUsage[targetMonth - 1]);
		        }
		    }
		    
		    // 차트 지우기
		    if (Chart1) {
		        Chart1.destroy();
		    }
		 	// 차트1
		    let prevUsageChart = $('#prevUsageChart')[0].getContext('2d');
		    Chart1 = new Chart(prevUsageChart, {
		        type: 'bar',
		        data: {
		            labels: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
		            datasets: [
		            	{
			                label: year-1+"년",
			                data: [prevAllUsage[0], prevAllUsage[1], prevAllUsage[2], prevAllUsage[3],
			                	prevAllUsage[4], prevAllUsage[5], prevAllUsage[6], prevAllUsage[7],
			                	prevAllUsage[8], prevAllUsage[9], prevAllUsage[10], prevAllUsage[11]],
			                backgroundColor: [
			                    'rgb(88, 121, 136)'
			                ],
			                borderColor: [
			                    'rgb(88, 121, 136)'
			                ],
			                borderWidth: 1
		                },
		            	{
			                label: year+"년",
			                data: [yearAllUsage[0], yearAllUsage[1], yearAllUsage[2], yearAllUsage[3],
			                	yearAllUsage[4], yearAllUsage[5], yearAllUsage[6], yearAllUsage[7],
			                	yearAllUsage[8], yearAllUsage[9], yearAllUsage[10], yearAllUsage[11]],
			                backgroundColor: [
			                    'rgb(178, 211, 226)'
			                ],
			                borderColor: [
			                    'rgb(178, 211, 226)'
			                ],
			                borderWidth: 1
		                }
		            	]
		        },
		        options: {
		            scales: {
		                x: {
		                    ticks: {
		                        color: 'white'  // x축 라벨 텍스트 색상 (예: 파란색)
		                    }
		                },
		                y: {
		                    beginAtZero: true,
		                    ticks: {
		                        color: 'white'  // y축 눈금 텍스트 색상 (예: 주황색)
		                    }
		                }
		            }
		        }
		    });
		 	// 차트 지우기
		    if (Chart2) {
		        Chart2.destroy();
		    }
		 	// 차트2
		    let sMonthUsageChart = $('#sMonthUsageChart')[0].getContext('2d');
		    Chart2 = new Chart(sMonthUsageChart, {
		        type: 'bar',
		        data: {
		            labels: sMonthLabels,
		            datasets: [{
		                label: "전력 사용량",
		                data: sMonthData,
		                backgroundColor: [
		                	'rgb(28, 61, 76)',
		                	'rgb(58, 91, 106)',
		                	'rgb(88, 121, 136)',
		                	'rgb(118, 151, 166)',
		                	'rgb(148, 181, 196)',
		                	'rgb(178, 211, 226)',
		                    
		                ],
		                borderColor: [
		                	'rgb(28, 61, 76)',
		                	'rgb(58, 91, 106)',
		                	'rgb(88, 121, 136)',
		                	'rgb(118, 151, 166)',
		                	'rgb(148, 181, 196)',
		                	'rgb(178, 211, 226)',
		                ],
		                borderWidth: 1
		            }]
		        },
		        options: {
		    		plugins: {
		    			legend: {
		                    display: false   // 범례
		                }
		    		},
		            scales: {
		                x: {
		                    ticks: {
		                        color: 'white'  // x축 라벨 텍스트 색상 (예: 파란색)
		                    }
		                },
		                y: {
		                    beginAtZero: true,
		                    ticks: {
		                        color: 'white'  // y축 눈금 텍스트 색상 (예: 주황색)
		                    }
		                }
		            }
		        }
		    });
			 // 차트 지우기
		    if (Chart3) {
		        Chart3.destroy();
		    }
		 	// 차트3
		   	let monthUsageChart = $('#monthUsageChart')[0].getContext('2d');
		    Chart3 = new Chart(monthUsageChart, {
		        type: 'bar',
		        data: {
		            labels: [year-4+'년', year-3+'년', year-2+'년', year-1+'년', year+'년'],
		            datasets: [{
		                label: '전력 사용량',
		                data: [month4Years[0], month4Years[1], month4Years[2], month4Years[3],
		                	yearAllUsage[month-1]],
		                backgroundColor: [
		                	'rgb(58, 91, 106)',
		                	'rgb(88, 121, 136)',
		                	'rgb(118, 151, 166)',
		                	'rgb(148, 181, 196)',
		                	'rgb(178, 211, 226)',
		                ],
		                borderColor: [
		                	'rgb(58, 91, 106)',
		                	'rgb(88, 121, 136)',
		                	'rgb(118, 151, 166)',
		                	'rgb(148, 181, 196)',
		                	'rgb(178, 211, 226)',
		                ],
		                borderWidth: 1
		            }]
		        },
		        options: {
		    		plugins: {
		    			legend: {
		                    display: false   // 범례
		                }
		    		},
		            scales: {
		                x: {
		                    ticks: {
		                        color: 'white'  // x축 라벨 텍스트 색상 (예: 파란색)
		                    }
		                },
		                y: {
		                    beginAtZero: true,
		                    ticks: {
		                        color: 'white'  // y축 눈금 텍스트 색상 (예: 주황색)
		                    }
		                }
		            }
		        }
		    });
		    
		    // 차트4 부분
		    $("#mainH1").text($(this).find('h2').text()+" "+year+"년 전력 사용량 분석");
		    $("#nowH21").text(month+"월 사용량 예측");
		    $("#nowH22").text(yearAllUsage[month-1]+" GWh");
		    // 이번달 전력 사용량 평균값 구하기
		    let usageRate = 0;
		    if (nowMonthAll !== 0) { // 0으로 나누기 방지
		        usageRate = (yearAllUsage[month - 1] / nowMonthAll) * 100;
		        usageRate = usageRate.toFixed(2); // 소수 둘째자리까지 반올림
		    } else {
		        usageRate = "0.00"; // 혹시나 전체 사용량이 0일 때 대비
		    }
		    // 원형차트에 글씨넣는 플러그인
		    const centerTextPlugin = {
		    		  id: 'centerText',
		    		  beforeDraw(chart) {
		    		    const ctx = chart.ctx;
		    		    const {top, bottom, left, right} = chart.chartArea;

		    		    ctx.save();

		    		    // 중앙 좌표 계산
		    		    const centerX = (left + right) / 2;
		    		    const centerY = (top + bottom) / 2;

		    		    ctx.textAlign = 'center';
		    		    ctx.textBaseline = 'middle';

		    		    ctx.font = 'bold 16px Arial';  // 글꼴, 크기 조정 가능
		    		    ctx.fillStyle = 'white';        // 글씨 색상

		    		    ctx.fillText(region, centerX, centerY - 10);
		    		    ctx.fillText(" "+usageRate+"%", centerX, centerY + 10);

		    		    ctx.restore();
		    		  }
		    };
			// 차트 지우기
		    if (Chart4) {
		        Chart4.destroy();
		    }
		    let nowUsageChart = $('#nowUsageChart')[0].getContext('2d');
		    Chart4 = new Chart(nowUsageChart, {
		    	  type: 'doughnut',
		    	    data: {
		    	    	labels: [$(this).find('h2').text()+" 전력 사용량", "전체 전력 사용량"],
		    	      	datasets: [{
			    	        data: [yearAllUsage[month-1], nowMonthAll],
			    	        backgroundColor: [
			    	        	'rgb(88, 121, 136)',
			    	   			'rgb(178, 211, 226)'
			    	        ],
		    	        borderWidth: 0,
		    	        scaleBeginAtZero: true,
		    	      }
		    	    ]
		    	  },
		    	  options: {
		    		plugins: {
		    			legend: {
		                    display: false   // 범례
		                },
		    			centerText: true
		    		}
		    	},
		   		plugins: [centerTextPlugin]
		    });
		    
		    // 차트5
		    // 다음달 전력 사용량 예측값 가져오기
		    let nextUsage = await predictAndReturnCorrect($element, year, month + 1);
		    
		    $("#nowH23").text(month+1+"월 사용량 예측");
		    $("#nowH24").text(yearAllUsage[month-1]+" GWh");
			// 차트 지우기
		    if (Chart5) {
		        Chart5.destroy();
		    }
		    let nextUsageChart = $('#nextUsageChart')[0].getContext('2d');
		    Chart5 = new Chart(nextUsageChart, {
		    	  type: 'doughnut',
		    	    data: {
		    	    	labels: [$(this).find('h2').text()+" 전력 사용량", "전체 전력 사용량"],
		    	      	datasets: [{
			    	        data: [nextUsage, nowMonthAll],
			    	        backgroundColor: [
			    	        	'rgb(88, 121, 136)',
				    	        'rgb(178, 211, 226)'
			    	        ],
		    	        borderWidth: 0,
		    	        scaleBeginAtZero: true,
		    	      }
		    	    ]
		    	  },
		    	  options: {
		    		plugins: {
		    			legend: {
		                    display: false   // 범례
		                },
		    			centerText: true
		    		}
		    	},
		   		plugins: [centerTextPlugin]
		    });
		});
		// 사이트 로드시 서울정보 가져오기
		$("#seoul").click();

	});
</script>
</head>
<body>
<div id="main1">
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
	<div id="main">
		<div id="prevUsageBox">
			<h2>전년도 대비 사용량</h2>
			<canvas id="prevUsageChart" width="870" height="380"></canvas>
		</div>
		<div id="monthUsageBox">
			<h1 id="mainH1">서울 2025년 전력 사용량 분석</h1>
			<div id="chartBox">
				<div id="chart4Box"><canvas id="nowUsageChart" width="200" height="200"></canvas></div>
				<div id="chart5Box"><canvas id="nextUsageChart" width="200" height="200"></canvas></div>
				<div id="nowMonthBox1"><h2 id="nowH21">월 사용량 예측</h2><h2 id="nowH22">0000.00 GWh</h2></div>
				<div id="nowMonthBox2"><h2 id="nowH23">월 사용량 예측</h2><h2 id="nowH24">0000.00 GWh</h2></div>
			</div>
		</div>
		<div id="sMonthUsageBox">
			<h2>최근 6개월 사용량</h2>
			<canvas id="sMonthUsageChart" width="670" height="380"></canvas>
		</div>
		<div id="yearUsageBox">
			<h2>최근 5년 6월 사용량</h2>
			<canvas id="monthUsageChart" width="670" height="380"></canvas>
		</div>
	</div>
</div>
<h1 id="result"></h1>
</body>
</html>