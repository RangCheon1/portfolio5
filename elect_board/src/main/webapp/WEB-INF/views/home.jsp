<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="false" %>
<html>
<head>
  <title>Home</title>
  <style>
  	div{
  	box-sizing:border-box;
  	}
    .middle {  
    position:relative;
	display:inline-block;
	vertical-align: top;
	width:45%;
	height:800px;
    }
    .year-select-container{
    position: absolute;
    top: 10px;
    left: 10px;
    z-index: 10;
    background: rgba(255,255,255,0.8);
    padding: 5px;
    padding-left:320px;
    border-radius: 4px;
    }
    #usageTitle{
    display:inline-block;
    }
    #selectBox{
    display:inline-block;
    padding-left:220px;
    }
    .middle.map {
  	position: relative;
  	padding-left: 70px;
	}
	.chart{
	padding-top:130px;
	}
	.svg-map,
	.oversvg {
  	position: absolute;
  	padding-left:200px;
	}

	.svg-map {
  	z-index: 1;
  	top: 0;
  	left: 0;
  	width: 600px;
  	height: 800px;
	}
	
	.oversvg {
  	z-index: 2; /* 더 높은 z-index로 겹쳐짐 */
  	top:153;
  	left: 3;
  	pointer-events: none; /* 클릭은 SVG가 받도록 */
  	width: 600px;
  	height: 650px;
	}
  </style>
</head>
<body>
<div class="fullwide">
<div class="middle map">
	<div class="year-select-container">
  <label for="yearSelect">연도 선택: </label>
  <select id="yearSelect">
    <option value="2014" <c:if test="${year == 2014}">selected</c:if>>2014</option>
    <option value="2015" <c:if test="${year == 2015}">selected</c:if>>2015</option>
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
  </select>
  </div>
  <object class='svg-map' type="image/svg+xml"
          data="${pageContext.request.contextPath}/resources/static/svg/southKoreaLow.svg"
          width="600" height="800">
    브라우저가 SVG를 지원하지 않습니다.
  </object>
  <img src="${pageContext.request.contextPath}/resources/static/southKoreaLow.png" class="oversvg">
</div>

<div class="middle chart">

<h2 id="usageTitle">${year}년 ${region} 전력 사용량 그래프</h2>
<div id="selectBox">
  <label>도시:</label>
  <select id="citySelect">
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
</select>
  &nbsp;
  <label for="predictionType">모델:</label> 
  <select id="predictionType">
    <option value="short">단기 모델</option>
    <option value="long">장기 모델</option>
</select>
</div>
  <canvas id="usageChart" width="600" height="300"></canvas>
</div>
</div>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
	  const regionMapReverse = {};
	  for (const eng in regionMap) {
	    regionMapReverse[regionMap[eng]] = eng;
	  }
	
	  const base = '${pageContext.request.contextPath}';

	  let year = '<c:out value="${year != null ? year : '2023'}"/>';
	  let currentRegionKor = '<c:out value="${region != null ? region : '서울'}"/>';
	  let currentRegionEng = regionMapReverse[currentRegionKor];

	  const ctx = document.getElementById('usageChart').getContext('2d');
	  let usageData = new Array(12).fill(null);
	  let predictionData = new Array(12).fill(null);

	  // 차트 초기화: 두 개 데이터셋 (실제, 예측)
	  const chart = new Chart(ctx, {
	    type: 'bar',
	    data: {
	      labels: ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],
	      datasets: [
	        {
	          label: '실제 월별 전력 사용량',
	          data: usageData,
	          borderColor: 'rgba(75, 192, 192, 1)',
	          backgroundColor: 'rgba(75, 192, 192, 0.2)',
	          fill: false,
	          tension: 0.1,
	          yAxisID: 'y',
	        },
	        {
	          label: '예측 월별 전력 사용량',
	          data: predictionData,
	          borderColor: 'rgba(255, 99, 132, 1)',
	          backgroundColor: 'rgba(255, 99, 132, 0.2)',
	          fill: false,
	          tension: 0.1,
	          yAxisID: 'y',
	        }
	      ]
	    },
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          ticks: {
	            stepSize: 10
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
	        usageData = json.monthlyUsage;
	        chart.data.datasets[0].data = usageData;
	        chart.update();
	      })
	      .catch(err => {
	        console.error("실제 사용량 데이터 로딩 실패", err);
	        alert("실제 사용량 데이터 로딩 실패");
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
        data: { region: regionKor, year: year, month: month }
      }).then(prevUsage => {
        const usage = prevUsage.usage;
        if (!usage || usage === 0) {
          predictions[month - 1] = null;
          return;
        }
        const data = {
          city_encoded: cityEncoded,
          year: year,
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
      predictionData = predictions;
      chart.data.datasets[1].data = predictionData;
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
      predictionData = predictions;
      chart.data.datasets[1].data = predictionData;
      chart.update();
    });
  }
}

// refreshAll 함수에서 Promise 체인으로 처리
function refreshAll() {
  const predictionType = $('#predictionType').val();
  fetchUsageData(year, currentRegionKor).then(() => {
    return fetchPredictionData(year, currentRegionKor, predictionType);
  }).then(() => {
    
  }).catch(() => {
    
  });
}
	  // 연도 선택 변경
	  $('#yearSelect').on('change', function() {
	    year = $(this).val();
	    
	    $('#usageTitle').text(year+'년 '+currentRegionKor+" 전력 사용량 그래프")
	    refreshAll();
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
		  $('#usageTitle').text(year+'년 '+currentRegionKor+" 전력 사용량 그래프")
		  refreshAll();
		});
	$('#citySelect').val(currentRegionKor);
	
	waitForSvgAndBind();
	  refreshAll(); 
	  // SVG 지도 내 지역 클릭 시
	  function bindRegionEvents(svgDoc) {
	    const regions = svgDoc.querySelectorAll('.land');
	    regions.forEach(path => {
	      path.style.cursor = 'pointer';
	      path.addEventListener('click', () => {
	        const eng = path.getAttribute('title');
	        currentRegionEng = eng;
	        currentRegionKor = regionMap[eng];
	        if (!currentRegionKor) {
	          alert("알 수 없는 지역: " + eng);
	          return;
	        }
	        $('#citySelect').val(currentRegionKor);

	        $('#usageTitle').text(year+'년 '+currentRegionKor+" 전력 사용량 그래프")
	        
	        refreshAll();
	      });
	    });
	  }

	  // SVG object 감시 및 이벤트 바인딩
	  function waitForSvgAndBind() {
	    const svgObj = document.querySelector('object');
	    if (!svgObj) return console.error('SVG object not found');

	    const timer = setInterval(() => {
	      const svgDoc = svgObj.contentDocument;
	      if (!svgDoc) return;

	      clearInterval(timer);
	      bindRegionEvents(svgDoc);
	    }, 50);
	  }

	});
	
	
</script>
</body>
</html>