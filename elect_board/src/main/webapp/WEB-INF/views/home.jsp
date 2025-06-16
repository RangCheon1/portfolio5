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
    .map{
    padding-left:70px;
    }
    .year-select-container{
    position: absolute;
    top: 10px;
    left: 10px;
    z-index: 10;
    background: rgba(255,255,255,0.8);
    padding: 5px;
    padding-left:150px;
    border-radius: 4px;
    }
    #usageTitle{
    display:inline-block;
    }
    .middle.map {
  	position: relative;
  	padding-left: 70px;
	}

	.svg-map,
	.oversvg {
  	position: absolute;
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

  <h2 id="usageTitle">${year}년 ${region} 전력 사용량 그래프</h2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <label>도시:</label>&nbsp;
  <label>모델:</label> 
  <canvas id="usageChart" width="600" height="300"></canvas>
</div>
</div>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
  // 영어 -> 한글 지역명 맵핑
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

  // 한글 -> 영어 역맵핑 생성
  const regionMapReverse = {};
  for (const eng in regionMap) {
    regionMapReverse[regionMap[eng]] = eng;
  }

  let year = '${year}';

  // 초기 지역 한글명을 영어 key로 변환하여 저장
  let currentRegionKor = '${region}';  // ex) '강원도'
  let currentRegion = regionMapReverse[currentRegionKor];  // ex) 'Gangwon'

  const base = '${pageContext.request.contextPath}';

  const ctx = document.getElementById('usageChart').getContext('2d');
  const chart = new Chart(ctx, {
	  type: 'bar',  // line → bar 변경
	  data: {
	    labels: ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],
	    datasets: [{
	      label: ' 월별 전력 사용량',
	      data: [
	        <c:forEach var="m" items="${monthlyUsage}" varStatus="loop">
	          ${m}<c:if test="${!loop.last}">,</c:if>
	        </c:forEach>
	      ],
	      backgroundColor: 'rgba(75, 192, 192, 0.6)',  // 바 그래프는 borderColor 대신 backgroundColor가 주로 쓰임
	      borderColor: 'rgba(75, 192, 192, 1)',
	      borderWidth: 1
	    }]
	  },
	  options: {
	    scales: {
	      y: {
	        beginAtZero: true,
	        ticks: {
	          stepSize: 10  // 필요하면 y축 간격 설정
	        }
	      }
	    }
	  }
	});

  // 연도 선택 변경시
  document.getElementById('yearSelect').addEventListener('change', e => {
    year = e.target.value;
    updateRegion(currentRegion);
  });

  // SVG 로드 후 각 지역 클릭 이벤트 설정
  window.addEventListener('DOMContentLoaded', () => {
    const svgObj = document.querySelector('object');
    svgObj.addEventListener('load', () => {
      const svgDoc = svgObj.contentDocument;
      const regions = svgDoc.querySelectorAll('.land');

      regions.forEach(path => {
        path.style.cursor = 'pointer';
        path.addEventListener('click', () => {
          const engRegion = path.getAttribute('title');  // 영어 key
          currentRegion = engRegion;  // 클릭한 영어 key로 현재 지역 갱신
          updateRegion(engRegion);
        });
      });
    });
  });

  // 지역 및 연도 기준 데이터 갱신 함수
  function updateRegion(engRegionName) {
    const selectedRegionKor = regionMap[engRegionName];

    if (!selectedRegionKor) {
      alert("알 수 없는 지역: " + engRegionName);
      return;
    }

    fetch(base + '/api/usage/' + year + '?region=' + encodeURIComponent(selectedRegionKor))
      .then(res => res.json())
      .then(json => {
        const h2 = document.getElementById("usageTitle");
        h2.textContent = year + "년 " + selectedRegionKor + " 전력 사용량 그래프";

        chart.data.datasets[0].label = `${selectedRegionKor} 월별 전력 사용량`;
        chart.data.datasets[0].data = json.monthlyUsage;
        chart.update();
      })
      .catch(err => {
        console.error(err);
        alert("데이터 로딩 실패");
      });
  }
</script>
</body>
</html>