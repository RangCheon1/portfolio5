$(function () {
	  /* ----------------------------------------
	     0. 새로고침해도 무조건 맨 위에서 시작
	  ---------------------------------------- */
	  if ('scrollRestoration' in history) {
	      history.scrollRestoration = 'manual';   // 🔸 스크롤 상태 복원 OFF
	  }
	  let $root = $('html, body');              // 크로스‑브라우징용
	  $root.scrollTop(0);                         // 첫 진입 강제 top

	  /* ----------------------------------------
	     1. 기본 변수 & 헬퍼
	  ---------------------------------------- */
	  let page  = 1;
	  let total = $('.pagediv').length;         // 페이지(div) 개수

	  function go(n) {                            // n = 1,2,3 ...
	    if (n < 1 || n > total) return;
	    page = n;

	    let posTop = (page - 1) * $(window).height();
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
	  $('#three').on('click',() => go(3));
	});

$(document).ready(function() {
let cityCodeMap = {
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

let regionMap = {
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
let fixedColors = [
  'rgb(28, 61, 76)',     // 1
  'rgb(37, 70, 84)',     // 2
  'rgb(47, 79, 92)',     // 3
  'rgb(56, 88, 100)',    // 4
  'rgb(66, 97, 109)',    // 5
  'rgb(75, 106, 117)',   // 6
  'rgb(85, 115, 125)',   // 7
  'rgb(94, 124, 133)',   // 8
  'rgb(104, 133, 141)',  // 9
  'rgb(113, 142, 149)',  // 10
  'rgb(123, 151, 157)',  // 11
  'rgb(132, 160, 165)',  // 12
  'rgb(142, 169, 173)',  // 13
  'rgb(151, 178, 181)',  // 14
  'rgb(161, 187, 189)',  // 15
  'rgb(170, 196, 197)',  // 16
  'rgb(180, 200, 210)'   // 17
];

let regionMapReverse = {};
for (let eng in regionMap) {
    regionMapReverse[regionMap[eng]] = eng;
}

let initTag = document.getElementById('initData');
let year = initTag.dataset.year;
let currentRegionKor = initTag.dataset.region;
let currentRegionEng = regionMapReverse[currentRegionKor];

let ctx = document.getElementById('usageChart').getContext('2d');
let usageData = new Array(12).fill(null);
let predictionData = new Array(12).fill(null);

$('#yearButtons').on('click', '.year-btn', function() {
    let selectedYear = $(this).data('year');

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
    donut2(year);
  });

// 차트 초기화: 두 개 데이터셋 (실제, 예측)
let chart = new Chart(ctx, {
    data: {
        labels: ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],
        datasets: [
            {   // 라인 차트 (예측) 먼저 작성 → 위로 표시됨
                type: 'line',
                label: '실제 월별 전력 사용량',
                data: predictionData,
                borderColor: 'rgb(235, 79, 112)',
                backgroundColor: 'rgb(235, 79, 112)',
                fill: false,
                tension: 0.1,
                yAxisID: 'y',
                datalabels: {
                    display: false
                },
                borderWidth: 3,      // 라인 더 두껍게 (선택)
                pointRadius: 5      // 점 크기 (선택)
            },
            {   // 바 차트 (실제) 나중 작성 → 아래로 표시됨
                type: 'bar',
                label: '예측 월별 전력 사용량',
                data: usageData,
                borderColor: [
                	  'rgb(28, 61, 76)',    // 1월
                	  'rgb(42, 74, 88)',    // 2월
                	  'rgb(56, 87, 100)',   // 3월
                	  'rgb(70, 100, 112)',  // 4월
                	  'rgb(84, 113, 124)',  // 5월
                	  'rgb(98, 126, 136)',  // 6월
                	  'rgb(112, 139, 148)', // 7월
                	  'rgb(126, 152, 160)', // 8월
                	  'rgb(140, 165, 172)', // 9월
                	  'rgb(154, 178, 184)', // 10월
                	  'rgb(168, 191, 196)', // 11월
                	  'rgb(180, 200, 210)'  // 12월
                ],
                backgroundColor: [
                	  'rgb(28, 61, 76)',    // 1월
                	  'rgb(42, 74, 88)',    // 2월
                	  'rgb(56, 87, 100)',   // 3월
                	  'rgb(70, 100, 112)',  // 4월
                	  'rgb(84, 113, 124)',  // 5월
                	  'rgb(98, 126, 136)',  // 6월
                	  'rgb(112, 139, 148)', // 7월
                	  'rgb(126, 152, 160)', // 8월
                	  'rgb(140, 165, 172)', // 9월
                	  'rgb(154, 178, 184)', // 10월
                	  'rgb(168, 191, 196)', // 11월
                	  'rgb(180, 200, 210)'  // 12월
                ],
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
                    color: '#ececec'
                }
            },
            y: {
                beginAtZero: true,
                ticks: {
                    color: '#ececec',
                    stepSize: 1000  // 눈금 간격
                }
            }
        },
        plugins: {
            legend: {
                labels: {
                    color: '#ececec' // 범례 글씨 색
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
	let cityEncoded = cityCodeMap[regionKor];
		if (cityEncoded === undefined) {
		alert('알 수 없는 도시명입니다.');
	return Promise.reject('Unknown city');
	}

	let predictions = new Array(12).fill(null);

	if (predictionType === 'short') {
	// 단기 모델: 각 월별 이전 사용량 받아서 예측 요청
	let promises = [];
	for (let month = 1; month <= 12; month++) {
  		let promise = $.ajax({
    		url: '/getPrevUsage',
    		method: 'GET',
    		dataType: 'json',
    		data: { region: regionKor, year: year-1, month: month }
  		}).then(prevUsage => {
    		let usage = prevUsage.usage;
    	if (!usage || usage === 0) {
      		predictions[month - 1] = null;
      		return;
    	}
    	let data = {
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
	let promises = [];
	for (let month = 1; month <= 12; month++) {
  		let data = {
    		city_encoded: cityEncoded,
    		year: year,
    		month: month
  		};
  		let promise = $.ajax({
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
	let predictionType = $('#predictionType').val();
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
	let selectedKor = $(this).val();
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
let regions = svgDoc.querySelectorAll('.land');
regions.forEach(path => {
    path.style.cursor = 'pointer';
    path.addEventListener('click', () => {
        let eng = path.getAttribute('title');
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
	let paths = svgDoc.querySelectorAll('.land');
	paths.forEach(p => {
    	let title = p.getAttribute('title');
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
	let selectedKor = $(this).val();
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
		let svgObj = document.querySelector('.svg-map');
	if (!svgObj) {
	console.error('SVG object not found');
return;
	}

	/* ① load 이벤트가 미래에 올 수도 있으니 일단 등록 */
	svgObj.addEventListener('load', () => tryBind(svgObj));

	/* ② 이미 load 가 끝났거나, load 전에 캐싱돼 버린 경우 대비
    → 일정 시간 동안 주기적으로 contentDocument 를 확인 */
	let MAX_TRY   = 20;   // 최대 2초 (20 × 100 ms)
	let   tryCount  = 0;
	let timer = setInterval(() => {
    if (tryBind(svgObj) || ++tryCount >= MAX_TRY) {
  	clearInterval(timer);   // 성공했거나, 2초가 지나면 멈춤
	}
	}, 100);
}

/* 실제 바인딩: 성공하면 true, 아직 준비 안 됐으면 false */
function tryBind(svgObj) {
		let svgDoc = svgObj.contentDocument;
	if (!svgDoc) return false;

	/* 중복 바인딩 방지: 한 번이라도 성공했으면 바로 true */
	if (svgDoc.__bound) return true;
	svgDoc.__bound = true;          // 플래그 달아두기

	injectSvgStyles(svgDoc);
	bindRegionEvents(svgDoc);
	return true;
}

function injectSvgStyles(svgDoc) {
	let style = svgDoc.createElementNS('http://www.w3.org/2000/svg', 'style');
	style.textContent = `
		.selectedsvg {
			
		}
		.elsesvg {
			
		}
	`;
svgDoc.documentElement.appendChild(style);
}

let totalCtx = document
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
        backgroundColor: 'rgb(235, 79, 112)',
        borderColor: 'rgb(235, 79, 112)',
        borderWidth: 1
    },
    {
        label: '예측 총 사용량',
        data: [0],
        backgroundColor: 'rgb(180, 200, 210)',
        borderColor: 'rgb(180, 200, 210)',
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
let donutChart2 = null;

function donut(selectedYear) {
  let apiUrl = '/api/usage/total/' + selectedYear;

  $.getJSON(apiUrl).done(data => {
	
	// 값이 큰 순대로 정렬
	data.sort((a, b) => (Number(b.totalUsage) || 0) - (Number(a.totalUsage) || 0));
    /* 데이터·색상 준비 */
    let labels = data.map(d => d.region);
    let usage  = data.map(d => Number(d.totalUsage) || 0);

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
    let ctx = document.getElementById('usageDonutChart').getContext('2d');
    donutChart = new Chart(ctx, {
    	  type: 'doughnut',
    	  data: {
    	    labels,
    	    datasets: [{
    	      label: `${selectedYear}년도 지역별 총 사용량`,
    	      data: usage,
    	      backgroundColor: fixedColors.slice(0, labels.length),
    	      borderWidth: 0
    	    }]
    	  },
    	  options: {
    	    responsive: false,
    	    plugins: {
    	      legend: { display: false },
    	      tooltip: {
    	        callbacks: {
    	          label: function(context) {
    	            let value = context.parsed;
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

// 두번째 도넛차트 데이터 가져오기
async function getYearlyPredictionSum(year) {
    let citys = ['강원도', '경기도', '경상남도', '경상북도', '광주', '대구', '대전', '부산', '서울', '세종', '울산', '인천', '전라남도', '전라북도', '제주', '충청남도', '충청북도'];
    
    return new Promise(function(resolve, reject) {
        $.ajax({
            url: '/modelLongYearly',  // ✅ FastAPI 새 엔드포인트
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ year: year }), // ✅ 연도만 보냄
            success: function(response) {
                let predictions = response.predictions; // { "0": [12개값], "1": [...], ... }

                // 도시별 1~12월 합계
                let yearlySums = Object.keys(predictions).map(cityCode => {
                    let monthlyValues = predictions[cityCode]; // 12개 배열
                    let yearlySum = monthlyValues.reduce((sum, val) => sum + val, 0);
                    return yearlySum;
                });

                // 도시명 + 합계 묶기
                let cityUsageArray = citys.map((city, idx) => {
                    return { city: city, value: yearlySums[idx] };
                });

                // value 내림차순 정렬
                cityUsageArray.sort((a, b) => b.value - a.value);

                resolve(cityUsageArray);
            },
            error: function(xhr, status, error) {
                reject('FastAPI 호출 오류: ' + xhr.status + ' ' + error);
            }
        });
    });
}

// 두번째 도넛함수 그리기
function donut2(selectedYear){
	getYearlyPredictionSum(selectedYear).then(sortedArray => {	 
		
	    /* 데이터 준비 */
	    let labels = sortedArray.map(item => item.city);
	    let usage  = sortedArray.map(item => item.value);

	    /* ── 이미 차트가 있으면 업데이트만 ─────────────────── */
	    if (donutChart2) {
	      donutChart2.data.labels                    = labels;
	      donutChart2.data.datasets[0].data          = usage;
	      donutChart2.data.datasets[0].backgroundColor = fixedColors.slice(0, labels.length);
	      donutChart2.data.datasets[0].label         =
	        `${selectedYear}년도 지역별 총 사용량`;
	        donutChart2.options.plugins.datalabels.formatter = function(value, context) {
	            return context.chart.data.labels[context.dataIndex]; // ✅ 항상 지역명
	          };
	      donutChart2.update();
	      return;
	    }
	    
    	let ctx = document.getElementById('usageDonutChart2').getContext('2d');
    	donutChart2 = new Chart(ctx, {
    	  type: 'doughnut',
    	  data: {
    	    labels: labels,
    	    datasets: [{
    	      label: `${selectedYear}년도 지역별 총 사용량`,
    	      data: usage,
    	      backgroundColor: fixedColors.slice(0, labels.length),
    	      borderWidth: 0
    	    }]
    	  },
    	  options: {
    	    responsive: false,
    	    plugins: {
    	      legend: { display: false },
    	      tooltip: {
    	        callbacks: {
    	          label: function(context) {
    	            let value = context.parsed;
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
	});
}
donut2(year);
});