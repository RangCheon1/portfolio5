<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>스크롤 페이징 템플릿</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/short.css" />
</head>
<body>
<header>
        <table class='header-table'>
        <tr>
            <td id="one"><p class="current_class navi">firstdiv</p></td>
        </tr>
        <tr>
        	<td id="two"><p class="navi">seconddiv</p></td>
        </tr>
        <tr>
        	<td id="three"><p class="navi"><a href='/usageChart' >thirddiv</a></p></td>
        </tr>
        </table>
</header>
<main>
<div id='firstdiv' class='pagediv'>
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
</div>
<div id='seconddiv' class='pagediv'>
<div class="fullwide">
		<div class='middle left'>
			<div class='left-up'>
				<p class="donut-title">도시별 총 전력<br>실제 사용량 비교</p>
  				<canvas id="usageDonutChart" width="375" height="375"></canvas>
			</div>
			<div class='left-down'>
			<div id="yearButtons" class="year-buttons">
			<table id='year-table'>
			<tr>
			<td><button type="button" data-year="2015" class="year-btn">2015</button></td>
			<td><button type="button" data-year="2016" class="year-btn">2016</button></td>
			<td><button type="button" data-year="2017" class="year-btn">2017</button></td>
			<td><button type="button" data-year="2018" class="year-btn">2018</button></td>
			</tr>
			<tr>
			<td><button type="button" data-year="2019" class="year-btn">2019</button></td>
			<td><button type="button" data-year="2020" class="year-btn">2020</button></td>
			<td><button type="button" data-year="2021" class="year-btn">2021</button></td>
			<td><button type="button" data-year="2022" class="year-btn">2022</button></td>
			</tr>
			<tr>
			<td><button type="button" data-year="2023" class="year-btn">2023</button></td>
			<td><button type="button" data-year="2024" class="year-btn">2024</button></td>
			<td><button type="button" data-year="2025" class="year-btn">2025</button></td>
			<td><button type="button" data-year="2026" class="year-btn">2026</button></td>
			</tr>
			<tr>
			<td><button type="button" data-year="2027" class="year-btn">2027</button></td>
			<td><button type="button" data-year="2028" class="year-btn">2028</button></td>
			<td><button type="button" data-year="2029" class="year-btn">2029</button></td>
			<td><button type="button" data-year="2030" class="year-btn">2030</button></td>
			</tr>
			</table>
			</div>
			</div>
		</div>
		<div class='up'>
		<div class="middle chart">
			<h2 id="usageTitle" class='div-main-h2'>${year}년 ${region} 월별 전력 사용량 그래프</h2> <label class='annotation'>(단위/GWh)</label>
			<div id="selectBox">
				<label class='select-label2'>도시:</label> <select id="citySelect" class='select2' style="color:black;">
					<option value="강원도">강원도</option>
					<option value="경기도">경기도</option>
					<option value="경상남도">경상남도</option>
					<option value="경상북도">경상북도</option>
					<option value="광주">광주</option>
					<option value="대구">대구</option>
					<option value="대전">대전</option>
					<option value="부산">부산</option>
					<option value="서울">서울</option>
					<option value="세종">세종</option>
					<option value="울산">울산</option>
					<option value="인천">인천</option>
					<option value="전라남도">전라남도</option>
					<option value="전라북도">전라북도</option>
					<option value="제주도">제주도</option>
					<option value="충청남도">충청남도</option>
					<option value="충청북도">충청북도</option>
				</select> &nbsp; <label for="predictionType" class='select-label2'>모델&nbsp;<input type='button' value='?' class='explain-button' style="color:black;"> :</label>
				
				<select id="predictionType" class='select2' style="color:black;">
					<option value="short">단기 모델</option>
					<option value="long">장기 모델</option>
				</select>
				
				<div id="modelExplainBox" class="explain-box" style="display:none; color:black;">
    				• <b style="color:black;">단기 모델</b> : 직전 1년치 월별 사용량을 입력값으로 삼아<br>다음 1년을 예측합니다. 예상 정확도가 높습니다.<br>
    				• <b style="color:black;">장기 모델</b> : 시·도별 월별 전력 사용량으로 장기적인<br>추세를 예측합니다. 예상 정확도는 단기 모델에 비해 낮습니다.<br>
				</div>
			</div>
			<canvas id="usageChart" width="600" height="350"></canvas>
			
		</div>
		<div class='middle down'>
		<h2 id='totalTitle' class='div-main-h2'>2015년 강원도 총 전력 사용량</h2> <label class='annotation'>(단위/GWh)&nbsp;&nbsp;&nbsp;&nbsp; <br>※총 예측 사용량은 그 해의 실제 사용량이 존재하지 않으면 그 해 전체, 존재하면 존재하는 달 까지만 합산됩니다.</label><br>
			<div id='t-text-container'>
				<div class='t-text tt1'>
				<h2 id='totalUse' class='t-h2'></h2>
				총 전력 사용량
				</div>
				<div class='t-text tt2'>
				<h2 id='totalPre' class='t-h2'></h2>
				총 예측 사용량
				</div>
			</div>
		<canvas id="totalChart" width="600" height="120"></canvas>
		</div>
		</div>
		<div class="middle map">
			<%-- <div class="year-select-container">
				<label for="yearSelect" class='select-label'>연도 선택: </label> <select id="yearSelect" class='select'>
					<option value="2015" <c:if test="${year == null || year == 2015}">selected</c:if>>2015</option>
					<option value="2016" <c:if test="${year == 2016}">selected</c:if>>2016</option>
					<option value="2017" <c:if test="${year == 2017}">selected</c:if>>2017</option>
					<option value="2018" <c:if test="${year == 2018}">selected</c:if>>2018</option>
					<option value="2019" <c:if test="${year == 2019}">selected</c:if>>2019</option>
					<option value="2020" <c:if test="${year == 2020}">selected</c:if>>2020</option>
					<option value="2021" <c:if test="${year == 2021}">selected</c:if>>2021</option>
					<option value="2022" <c:if test="${year == 2022}">selected</c:if>>2022</option>
					<option value="2023" <c:if test="${year == 2023}">selected</c:if>>2023</option>
					<option value="2024" <c:if test="${year == 2024}">selected</c:if>>2024</option>
					<option value="2025" <c:if test="${year == 2025}">selected</c:if>>2025</option>
					<option value="2026" <c:if test="${year == 2026}">selected</c:if>>2026</option>
					<option value="2027" <c:if test="${year == 2027}">selected</c:if>>2027</option>
					<option value="2028" <c:if test="${year == 2028}">selected</c:if>>2028</option>
					<option value="2029" <c:if test="${year == 2029}">selected</c:if>>2029</option>
					<option value="2030" <c:if test="${year == 2030}">selected</c:if>>2030</option>
				</select>
			</div> --%>
			<object class='svg-map' type="image/svg+xml"
				data="${pageContext.request.contextPath}/resources/static/svg/southKoreaLow4.svg"> 브라우저가 SVG를 지원하지 않습니다. </object>
			<img
				src="${pageContext.request.contextPath}/resources/static/southKoreaLow3.png"
				class="oversvg">
		</div>
	</div>
</div>
<!-- <div id='thirddiv' class='pagediv'>

</div> -->
</main>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>
<script src="//code.jquery.com/jquery-migrate-3.5.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<script>
  /* 플러그인 한 번만 등록 */
  Chart.register(ChartDataLabels);
</script>
<script>
$(function () {
	  /* ----------------------------------------
	     0. 새로고침해도 무조건 맨 위에서 시작
	  ---------------------------------------- */
	  if ('scrollRestoration' in history) {
	      history.scrollRestoration = 'manual';   // 🔸 스크롤 상태 복원 OFF
	  }
	  const $root = $('html, body');              // 크로스‑브라우징용
	  $root.scrollTop(0);                         // 첫 진입 강제 top

	  /* ----------------------------------------
	     1. 기본 변수 & 헬퍼
	  ---------------------------------------- */
	  let page  = 1;
	  const total = $('.pagediv').length;         // 페이지(div) 개수

	  function go(n) {                            // n = 1,2,3 ...
	    if (n < 1 || n > total) return;
	    page = n;

	    const posTop = (page - 1) * $(window).height();
	    $root.stop().animate({ scrollTop: posTop }, 600, 'easeOutCirc');

	    $('.navi').removeClass('current_class')
	              .eq(page - 1).addClass('current_class');
	  }

	  /* ----------------------------------------
	     2. 휠 스크롤
	  ---------------------------------------- */
	  $(window).on('wheel', function (e) {
		  // menu 위에 있을 경우 return
		  if ($(e.target).closest('#menu').length > 0) return;

		  if ($('html, body').is(':animated')) return;


	    if (e.originalEvent.deltaY > 0 && page < total)      go(page + 1);
	    else if (e.originalEvent.deltaY < 0 && page > 1)     go(page - 1);
	  });

	  /* ----------------------------------------
	     3. 상단 내비 클릭
	  ---------------------------------------- */
	  $('#one').on('click',  () => go(1));
	  $('#two').on('click',  () => go(2));
	  /* $('#three').on('click',() => go(3)); */
	});
</script>
<script>

$(document).ready(function() {
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
    "제주도": 14,
    "충청남도": 15,
    "충청북도": 16
};

const regionMap = {
    "Seoul": "서울",
    "Busan": "부산",
    "Daegu": "대구",
    "Incheon": "인천",
    "Gwangju": "광주",
    "Daejeon": "대전",
    "Ulsan": "울산",
    "Gyeonggi": "경기도",
    "Gangwon": "강원도",
    "North Chungcheong": "충청북도",
    "South Chungcheong": "충청남도",
    "North Jeolla": "전라북도",
    "South Jeolla": "전라남도",
    "North Gyeongsang": "경상북도",
    "South Gyeongsang": "경상남도",
    "Jeju": "제주도",
    "Sejong": "세종"
};

//도넛 그래프 색상
const fixedColors = [
    '#FF6384', // 강원도
    '#36A2EB', // 경기도
    '#FFCE56', // 경상남도
    '#4BC0C0', // 경상북도
    '#9966FF', // 광주
    '#FF9F40', // 대구
    '#C9CBCF', // 대전
    '#8D6E63', // 부산
    '#66BB6A', // 서울
    '#D4E157', // 세종
    '#BA68C8', // 울산
    '#7986CB', // 인천
    '#F06292', // 전라남도
    '#4DD0E1', // 전라북도
    '#AED581', // 제주도
    '#FFD54F', // 충청남도
    '#90A4AE' // 충청북도
];	

const regionMapReverse = {};
for (const eng in regionMap) {
    regionMapReverse[regionMap[eng]] = eng;
}

const base = '${pageContext.request.contextPath}';
let year = '<c:out value="${year != null ? year : '2015'}"/>';
let currentRegionKor = '<c:out value="${region != null ? region : '서울'}"/>';
let currentRegionEng = regionMapReverse[currentRegionKor];

const ctx = document.getElementById('usageChart').getContext('2d');
let usageData = new Array(12).fill(null);
let predictionData = new Array(12).fill(null);

$('#yearButtons').on('click', '.year-btn', function() {
    const selectedYear = $(this).data('year');

    if (year === selectedYear) return; // 이미 선택된 버튼이면 무시

    year = selectedYear;

    // 버튼 선택 스타일 변경
    $('.year-btn').removeClass('selected');
    $(this).addClass('selected');

    // UI 타이틀 변경
    $('#usageTitle').text(year + '년 ' + currentRegionKor + " 월별 전력 사용량 그래프");
    $('#totalTitle').text(year + '년 ' + currentRegionKor + " 총 전력 사용량");

    // 차트 및 도넛 갱신 호출
    refreshAll();
    donut(year);
  });

// 차트 초기화: 두 개 데이터셋 (실제, 예측)
const chart = new Chart(ctx, {
    
	
	
    data: {
    	labels: ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],
      	datasets: [
        {
          type: 'bar',
          label: '실제 월별 전력 사용량',
          data: usageData,
          borderColor: 'rgba(75, 192, 192, 1)',
          backgroundColor: 'rgba(75, 192, 192, 0.5)',
          fill: false,
          tension: 0.1,
          yAxisID: 'y',
          datalabels: {
              display: false
            }
        },
        {
          type: 'line',
          label: '예측 월별 전력 사용량',
          data: predictionData,
          borderColor: 'rgba(255, 99, 132, 1)',
          backgroundColor: 'rgba(255, 99, 132, 1)',
          fill: false,
          tension: 0.1,
          yAxisID: 'y',
          datalabels: {
              display: false
          }
        }
        ]
    },
    options: {
    	scales: {
    		x: {
    			ticks: {
    				color:'#ececec'
    			}
    		},
        	y: {
          		beginAtZero: true,
	        	ticks: {
	        		color:'#ececec',
	                stepSize:1000 // 눈금 간격 설정
	              }
        	}
      	},
      	plugins: {
      	    legend: {
      	      	labels: {
      	        	color: '#ececec' // 범례 항목 글자 색
      	      	}
      	    }
      	}
    }
});

// 실제 사용량 데이터 불러오기 및 차트 업데이트
function fetchUsageData(year, regionKor) {
	return fetch(base + '/api/usage/' + year + '?region=' + encodeURIComponent(regionKor))
    .then(res => res.json())
    .then(json => {
    	sumVal=0;
        usageData = json.monthlyUsage;
        chart.data.datasets[0].data = usageData;

        for(i=0;i<=chart.data.datasets[0].data.length-1;i++){
        	sumVal+=chart.data.datasets[0].data[i]*100
        	
        }
        chart.update();
    })
    .catch(err => {
        /* console.error("실제 사용량 데이터 로딩 실패", err);
        alert("실제 사용량 데이터 로딩 실패"); */
        for(i=0;i<=11;i++){
        	chart.data.datasets[0].data[i]=0;
        }
        sumVal=0;
        chart.update();
    });
}

// 예측 데이터 불러오기 (단기 or 장기)
function fetchPredictionData(year, regionKor, predictionType) {
	const cityEncoded = cityCodeMap[regionKor];
		if (cityEncoded === undefined) {
		alert('알 수 없는 도시명입니다.');
	return Promise.reject('Unknown city');
	}

	let predictions = new Array(12).fill(null);

	if (predictionType === 'short') {
	// 단기 모델: 각 월별 이전 사용량 받아서 예측 요청
	const promises = [];
	for (let month = 1; month <= 12; month++) {
  		const promise = $.ajax({
    		url: '/getPrevUsage',
    		method: 'GET',
    		dataType: 'json',
    		data: { region: regionKor, year: year-1, month: month }
  		}).then(prevUsage => {
    		const usage = prevUsage.usage;
    	if (!usage || usage === 0) {
      		predictions[month - 1] = null;
      		return;
    	}
    	const data = {
      		city_encoded: cityEncoded,
      		year: year-2014,
      		month: month,
      		prev_usage: usage
    	};
        return $.ajax({
      		url: '/modelShort',
      		method: 'POST',
      		contentType: 'application/json',
      		data: JSON.stringify(data)
    	}).then(response => {
      		predictions[month - 1] = response.prediction;
    	}).catch(() => {
      		predictions[month - 1] = null;
    	});
  	}).catch(() => {
    	predictions[month - 1] = null;
  	});
  		promises.push(promise);
	}
return Promise.all(promises).then(() => {
	//갱신마다 초기화
	sumPre=0;
  	predictionData = predictions;
  	chart.data.datasets[1].data = predictionData;
  	if(chart.data.datasets[0].data[0]!=0){
  		for(i=0;i<=chart.data.datasets[1].data.length-1;i++){
      		//총 예측 사용량은 실제 사용량이 존재하는 월까지만 합산
      		if(chart.data.datasets[0].data[i]!=0){
      			sumPre+=chart.data.datasets[1].data[i]*100
      		}
      		//실체 사용량이 0인 i달일 떄
      		else{
      				sumPre+=0;
      		}
        }
  	}
  	else{
  		for(i=0;i<=chart.data.datasets[1].data.length-1;i++){
  			sumPre+=chart.data.datasets[1].data[i]*100
  		}
  	}
  	chart.update();
});
	} else if (predictionType === 'long') {
	// 장기 모델: 바로 예측 요청
	const promises = [];
	for (let month = 1; month <= 12; month++) {
  		const data = {
    		city_encoded: cityEncoded,
    		year: year,
    		month: month
  		};
  		const promise = $.ajax({
    		url: '/modelLong',
    		method: 'POST',
    		contentType: 'application/json',
    		data: JSON.stringify(data)
  		}).then(response => {
    		predictions[month - 1] = response.prediction;
  		}).catch(() => {
    		predictions[month - 1] = null;
  		});
  		promises.push(promise);
		}
return Promise.all(promises).then(() => {
	//갱신마다 초기화
	sumPre=0;
  	predictionData = predictions;
  	chart.data.datasets[1].data = predictionData;
  	//1월 실제 사용량이 0이 아닐 때 (그 해의 실제 사용량이 전부 비어있지 않을 때)
  	if(chart.data.datasets[0].data[0]!=0){
  		for(i=0;i<=chart.data.datasets[1].data.length-1;i++){
      		//총 예측 사용량은 실제 사용량이 존재하는 월까지만 합산
      		if(chart.data.datasets[0].data[i]!=0){
      			sumPre+=chart.data.datasets[1].data[i]*100
      		}
      		else{
      				sumPre+=0;
      		}
        }
  	}
  	//1월 실제 사용량이 0일 때 (그 해의 실제 사용량이 전부 비어있을 때)
  	else{
  		for(i=0;i<=chart.data.datasets[1].data.length-1;i++){
  			sumPre+=chart.data.datasets[1].data[i]*100
  		}
  	}
  	chart.update();
});
}
}

// refreshAll 함수에서 Promise 체인으로 처리
function refreshAll() {
	const predictionType = $('#predictionType').val();
	  fetchUsageData(year, currentRegionKor)
	    .then(() =>
	      fetchPredictionData(year, currentRegionKor, predictionType)
	    )
	    .then(() => {
	      updateTotalChart();   // ⬅️ 합계 그래프 출력
	    })
	    .catch(() => {
	      alert('데이터 로딩 실패');
	    });
}
// 연도 선택 변경
$('#yearSelect').on('change', function() {
    year = $(this).val();
    
$('#usageTitle').text(year+'년 '+currentRegionKor+" 월별 전력 사용량 그래프")
$('#totalTitle').text(year+'년 '+currentRegionKor+" 총 전력 사용량")
    refreshAll();
	donut(year);
});

// 예측 타입 변경
$('#predictionType').on('change', function() {
	refreshAll();
});
$('#citySelect').on('change', function() {
	const selectedKor = $(this).val();
	if (!selectedKor) return;

	currentRegionKor = selectedKor;
	currentRegionEng = regionMapReverse[selectedKor];
	$('#usageTitle').text(year+'년 '+currentRegionKor+" 월별 전력 사용량 그래프");
	$('#totalTitle').text(year+'년 '+currentRegionKor+" 총 전력 사용량");
	refreshAll();
});
$('#citySelect').val(currentRegionKor);

waitForSvgAndBind();
refreshAll(); 
// SVG 지도 내 지역 클릭 시
function bindRegionEvents(doc) {
svgDoc = doc; // 전역 저장
const regions = svgDoc.querySelectorAll('.land');
regions.forEach(path => {
    path.style.cursor = 'pointer';
    path.addEventListener('click', () => {
        const eng = path.getAttribute('title');
        currentRegionEng = eng;
        currentRegionKor = regionMap[eng];
        if (!currentRegionKor) return;

        $('#citySelect').val(currentRegionKor);
        $('#usageTitle').text(year + '년 ' + currentRegionKor + " 월별 전력 사용량 그래프");
        $('#totalTitle').text(year+'년 '+currentRegionKor+" 총 전력 사용량");
        refreshAll();
        applySvgSelection(currentRegionEng);
    });
});
}

function applySvgSelection(regionEng) {
	if (!svgDoc) return;
	const paths = svgDoc.querySelectorAll('.land');
	paths.forEach(p => {
    	const title = p.getAttribute('title');
    	p.classList.remove('selectedsvg', 'elsesvg');
    if (title === regionEng) {
    	//클릭한 svg에 클래스 주기
        p.classList.add('selectedsvg');
    } else {
        p.classList.add('elsesvg');
    }
});
}

$('#citySelect').on('change', function() {
	const selectedKor = $(this).val();
	if (!selectedKor) return;

	currentRegionKor = selectedKor;
	currentRegionEng = regionMapReverse[selectedKor];

	$('#usageTitle').text(year + '년 ' + currentRegionKor + " 월별 전력 사용량 그래프");
	$('#totalTitle').text(year+'년 '+currentRegionKor+" 총 전력 사용량");
	refreshAll();
	applySvgSelection(currentRegionEng); // ✅ SVG 강조 적용
});

// SVG object 감시 및 이벤트 바인딩
function waitForSvgAndBind() {
		const svgObj = document.querySelector('.svg-map');
	if (!svgObj) {
	console.error('SVG object not found');
return;
	}

	/* ① load 이벤트가 미래에 올 수도 있으니 일단 등록 */
	svgObj.addEventListener('load', () => tryBind(svgObj));

	/* ② 이미 load 가 끝났거나, load 전에 캐싱돼 버린 경우 대비
    → 일정 시간 동안 주기적으로 contentDocument 를 확인 */
	const MAX_TRY   = 20;   // 최대 2초 (20 × 100 ms)
	let   tryCount  = 0;
	const timer = setInterval(() => {
    if (tryBind(svgObj) || ++tryCount >= MAX_TRY) {
  	clearInterval(timer);   // 성공했거나, 2초가 지나면 멈춤
	}
	}, 100);
}

/* 실제 바인딩: 성공하면 true, 아직 준비 안 됐으면 false */
function tryBind(svgObj) {
		const svgDoc = svgObj.contentDocument;
	if (!svgDoc) return false;

	/* 중복 바인딩 방지: 한 번이라도 성공했으면 바로 true */
	if (svgDoc.__bound) return true;
	svgDoc.__bound = true;          // 플래그 달아두기

	injectSvgStyles(svgDoc);
	bindRegionEvents(svgDoc);
	return true;
}

function injectSvgStyles(svgDoc) {
	const style = svgDoc.createElementNS('http://www.w3.org/2000/svg', 'style');
	style.textContent = `
		.selectedsvg {
			
		}
		.elsesvg {
			
		}
	`;
svgDoc.documentElement.appendChild(style);
}

const totalCtx = document
.getElementById('totalChart')
.getContext('2d');

totalChart = new Chart(totalCtx, {
	type: 'bar',
  	data: {
    	labels: ['총 전력 사용량'],
    	datasets: [
    {
        label: '실제 총 사용량',
        data: [0],
        backgroundColor: 'rgba(75, 192, 192, 0.5)',
        borderColor: 'rgba(75, 192, 192, 1)',
        borderWidth: 1
    },
    {
        label: '예측 총 사용량',
        data: [0],
        backgroundColor: 'rgba(255, 99, 132, 0.5)',
        borderColor: 'rgba(255, 99, 132, 1)',
        borderWidth: 1
    }
    ]
    },
  	options: {
		indexAxis: 'y',
    	scales: {
      	y: {
        	beginAtZero: true,
        	ticks: {
                color: '#ececec' // X축 텍스트 색상
              }
      	},
      	x: {
      		ticks: {
      	        color: '#ececec' // X축 텍스트 색상
      	    }
      	}
    	},
    
    	plugins: {
  	    legend: {
  	      	labels: {
  	        	color: '#ececec' // 범례 항목 글자 색
  	      	}
  	    },
  	  	datalabels: {
          display: false
        }
  		}
  	}
});

function updateTotalChart() {
	  totalChart.data.datasets[0].data[0] = sumVal/100;
	  totalChart.data.datasets[1].data[0] = sumPre/100;
	  $('#totalUse').text(totalChart.data.datasets[0].data[0]);
	  $('#totalPre').text(totalChart.data.datasets[1].data[0]);
	  totalChart.update();
}

$('.explain-button').on('click', function (e) {
    e.stopPropagation();                 // ← 문서 클릭 이벤트로 전파되지 않게
    $('#modelExplainBox').slideToggle(200);
});

// ② 박스 안을 눌러도 닫히지 않도록 전파 차단
$('#modelExplainBox').on('click', function (e) {
    e.stopPropagation();
});

// ③ 문서 아무 곳이나 클릭했을 때 박스가 열려 있으면 닫기
$(document).on('click', function (e) {
    // 클릭된 요소가 explain‑box나 버튼 계통이 아니면 → 닫기
    if (!$(e.target).closest('#modelExplainBox, .explain-button').length) {
        $('#modelExplainBox').slideUp(200);   // 이미 닫혀 있으면 무시
    }
});
let donutChart = null;   // 전역 핸들

function donut(selectedYear) {
  const apiUrl = '/api/usage/total/' + selectedYear;

  $.getJSON(apiUrl).done(data => {

    /* 데이터·색상 준비 */
    const labels = data.map(d => d.region);
    const usage  = data.map(d => Number(d.totalUsage) || 0);

    /* ── 이미 차트가 있으면 업데이트만 ─────────────────── */
    if (donutChart) {
      donutChart.data.labels                    = labels;
      donutChart.data.datasets[0].data          = usage;
      donutChart.data.datasets[0].backgroundColor = fixedColors.slice(0, labels.length);
      donutChart.data.datasets[0].label         =
        `${selectedYear}년도 지역별 총 사용량`;
        donutChart.options.plugins.datalabels.formatter = function(value, context) {
            return context.chart.data.labels[context.dataIndex]; // ✅ 항상 지역명
          };
      donutChart.update();
      return;
    }

    /* ── 처음 한 번만 차트 생성 ─────────────────────────── */
    const ctx = document.getElementById('usageDonutChart').getContext('2d');
    donutChart = new Chart(ctx, {
    	  type: 'doughnut',
    	  data: {
    	    labels,
    	    datasets: [{
    	      label: `${selectedYear}년도 지역별 총 사용량`,
    	      data: usage,
    	      backgroundColor: fixedColors.slice(0, labels.length),
    	      borderWidth: 1
    	    }]
    	  },
    	  options: {
    	    responsive: false,
    	    plugins: {
    	      legend: { display: false },
    	      tooltip: {
    	        callbacks: {
    	          label: function(context) {
    	            const value = context.parsed;
    	            return value.toLocaleString() + ' GWh';
    	          }
    	        }
    	      },
    	      datalabels: {
    	        color: 'rgb(33,28,57)',
    	        font: { weight: 'bold', size: 12 },
    	        textStrokeColor: 'white',                  // ✅ 테두리 색상
    	        textStrokeWidth: 2,                        // ✅ 테두리 두께
    	        formatter: function(value, context) {
    	          return context.chart.data.labels[context.dataIndex]; // ✅ 지역명 표시
    	        },
    	        anchor: function(context) {
    	            // 홀수/짝수 인덱스로 anchor 변경 → 지그재그 배치
    	            return context.dataIndex % 2 === 0 ? 'end' : 'start';
    	          },
    	          align: function(context) {
    	            return context.dataIndex % 2 === 0 ? 'start' : 'end';
    	          },
    	          offset: 30
    	      }
    	    }
    	  }
    	});
  }).fail(e => {
    alert('도넛 데이터를 불러오지 못했습니다: ' + e.statusText);
  });
}

donut(year);


});
</script>

<!-- 1번 div script -->

<script>
	$(document).ready(function(){
		let today = new Date();
	    let year = today.getFullYear();
	    let month = today.getMonth() + 1;
	    let nowMonthAll = 0.00;
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
		$(".menu").on("click", async function() {
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
			                	'rgb(58, 91, 106)'
			                ],
			                borderColor: [
			                	'rgb(58, 91, 106)'
			                ],
			                borderWidth: 1,
			                datalabels: {
			                    display: false
			                  }
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
			                borderWidth: 1,
			                datalabels: {
			                    display: false
			                  }
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
		                },
		          	  	datalabels: {
		                    display: false
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
		                },
		          	  	datalabels: {
		                    display: false
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
		    			centerText: true,
		    	  	  	datalabels: {
		    	            display: false
		    	          }
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
		    			centerText: true,
		    	  	  	datalabels: {
		    	            display: false
		    	          }
		    		}
		    	},
		   		plugins: [centerTextPlugin]
		    	
		    });
		});
		// 사이트 로드시 서울정보 가져오기
		$("#seoul").click();

	});
</script>
</body>
</html>