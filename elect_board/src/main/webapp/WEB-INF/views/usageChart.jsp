<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <title>전력 사용량 비교</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" type="text/css" href="/resources/css/styles.css" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <div id="page1" class="container">

        <!-- 조회 폼 -->
        <form id="searchForm">
            <!-- 연도, 지역, 그래프 표시 가로 배치 -->
            <div class="form-group flex-row" style="display: flex; align-items: center; gap: 20px;">
                <!-- 연도 선택 -->
                <div class="multi-select" tabindex="0">
                    <div class="select-box">연도 선택</div>
                    <div class="checkbox-list">
                        <c:forEach var="y" begin="2015" end="2030">
                            <label class="checkbox-item">
                                <input type="checkbox" name="years" value="${y}" 
                                    ${selectedYears != null && selectedYears.contains(y.toString()) ? "checked" : ""} />
                                ${y}년
                            </label>
                        </c:forEach>
                    </div>
                </div>

                <!-- 지역 선택 -->
                <div>
                    <label>지역 선택:</label>
                    <select name="region">
                        <option value="" disabled <c:if test="${empty selectedRegion}">selected</c:if>>
                            -- 지역을 선택하세요 --
                        </option>
                        <option value="all" <c:if test="${selectedRegion == 'all'}">selected</c:if>>전체</option>
                        <c:forEach var="r" items="${regionList}">
                            <option value="${r}" <c:if test="${selectedRegion == r}">selected</c:if>>
                                ${r}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- 그래프 표시 -->
                <div>
                    <label>그래프 표시:</label>
                    <select id="graphToggle" onchange="toggleGraphVisibility()">
                        <option value="both">모두 표시</option>
                        <option value="usage">실제 사용량만 표시</option>
                        <option value="predicted">예측 사용량(단기 + 장기)만 표시</option>
                        <option value="predicted_short">단기 예측 사용량만 표시</option>
                        <option value="predicted_long">장기 예측 사용량만 표시</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <input type="submit" value="조회" />
                <button id="downloadBtn" type="button">그래프 다운로드</button>
            </div>
        </form>

        <!-- 선택 정보 표시 -->
        <div class="info-group">
            <div class="info-card">
                <h3>선택한 정보</h3>
                <p id="selectedYearsDisplay"><strong>선택한 연도:</strong> 연도가 선택되지 않았습니다.</p>
                <p id="selectedRegionDisplay"><strong>선택한 지역:</strong> 선택한 지역이 없습니다.</p>
            </div>
        </div>

        <!-- 차트 영역 -->
        <div class="chart-row three-charts">
            <!-- 단기 예측 -->
            <div class="chart-container" style="position: relative;">
                <h3>단기 예측 전력 사용량 미리보기(실제 사용량 포함)</h3>
                <canvas id="predictedChart"></canvas>
                <div id="predictedChartOverlay" class="chart-overlay">지역, 연도를 선택해주세요.</div>
            </div>

            <!-- 장기 예측 -->
            <div class="chart-container" style="position: relative;">
                <h3>장기 예측 전력 사용량 미리보기(실제 사용량 포함)</h3>
                <canvas id="longTermChart"></canvas>
                <div id="longTermChartOverlay" class="chart-overlay">지역, 연도를 선택해주세요.</div>
            </div>

            <!-- 실제 사용량 -->
            <div class="chart-container" style="position: relative;">
                <div class="chart-header" 
                    style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px; padding: 5px 20px 0 10px;">
                    <h3 style="margin: 0;">월별 전력 사용량 미리보기</h3>
                    <div class="form-group" style="margin: 0;">
                        <label for="chartType" style="margin-right: 8px;">그래프 타입:</label>
                        <select id="chartType" onchange="updateChartType()">
                            <option value="bar">막대 그래프</option>
                            <option value="line">선형 그래프</option>
                        </select>
                    </div>
                </div>
                <canvas id="usageChart"></canvas>
                <div id="usageChartOverlay" class="chart-overlay">실제 전력 사용량이 없습니다.</div>
            </div>
        </div>

    </div>


<script>
//서버에서 전달받은 JSON 문자열을 자바스크립트 객체로 변환
const chartData = JSON.parse('${chartDataJson.replace("'", "\\'").replace("\"", "\\\"")}');
const allDataMap = JSON.parse('${allDataMapJson.replace("'", "\\'").replace("\"", "\\\"")}');

// 차트 x축 라벨 (월)
const labels = [
  '1월', '2월', '3월', '4월', '5월', '6월',
  '7월', '8월', '9월', '10월', '11월', '12월'
];

// 지역명을 숫자 코드로 매핑 (예측 API 요청에 사용)
const cityEncodeMap = {
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

// 기본 차트 타입 (bar, line 중 선택 가능)
let chartType = 'bar';

// 차트 객체들
let usageChart = null;      // 실제 사용량 차트 객체
let predictedChart = null;  // 단기 예측 차트 객체
let longTermChart = null;   // 장기 예측 차트 객체

// 차트 타입 변경 시 호출: 기존 차트 모두 파괴 후 재생성
let globalChartData = []; // 전역 변수

function updateChartType() {
    chartType = document.getElementById('chartType').value;
    if (usageChart) {
        usageChart.destroy();
        drawActualUsageChart(globalChartData || []);
    }
}

// 그래프 표시 옵션에 따라 차트 표시/숨김 처리
function toggleGraphVisibility() {
  const container = document.getElementById('page1');
  const selected = container.querySelector('#graphToggle').value;

  const usageContainer = container.querySelector('#usageChart').parentElement;
  const predictedContainer = container.querySelector('#predictedChart').parentElement;
  const longTermContainer = container.querySelector('#longTermChart').parentElement;

  // 초기화: 모두 숨김
  usageContainer.style.display = 'none';
  predictedContainer.style.display = 'none';
  longTermContainer.style.display = 'none';

  // 표시할 차트 보이기
  if (selected === 'usage') {
    usageContainer.style.display = 'block';
  } else if (selected === 'predicted') {
    predictedContainer.style.display = 'block';
    longTermContainer.style.display = 'block';
  } else if (selected === 'predicted_short') {
    predictedContainer.style.display = 'block';
  } else if (selected === 'predicted_long') {
    longTermContainer.style.display = 'block';
  } else if (selected === 'both') {
    usageContainer.style.display = 'block';
    predictedContainer.style.display = 'block';
    longTermContainer.style.display = 'block';
  }

  // 보이는 차트들을 배열에 담기
  const visibleCharts = [usageContainer, predictedContainer, longTermContainer]
    .filter(c => c.style.display === 'block');

  // 보이는 차트 개수에 따라 flex-basis와 max-width 설정
  const count = visibleCharts.length;

  if (count === 1) {
    visibleCharts[0].style.flexBasis = '100%';
    visibleCharts[0].style.maxWidth = '100%';
  } else if (count === 2) {
    visibleCharts.forEach(c => {
      c.style.flexBasis = '49%';
      c.style.maxWidth = '49%';
    });
  } else if (count === 3) {
    visibleCharts.forEach(c => {
      c.style.flexBasis = '32%';
      c.style.maxWidth = '32%';
    });
  }

  // 나머지 숨겨진 차트 스타일 초기화
  [usageContainer, predictedContainer, longTermContainer].forEach(c => {
    if (c.style.display !== 'block') {
      c.style.flexBasis = '';
      c.style.maxWidth = '';
    }
  });
}

//========================
//실제 사용량 차트 그리기 함수
//========================
function drawActualUsageChart(chartData) {
    const container = document.getElementById('page1');
    const canvas = container.querySelector('#usageChart');
    const overlay = container.querySelector('#usageChartOverlay');

    const selectedYears = Array.from(container.querySelectorAll('input[name="years"]:checked')).map(input => input.value);
    const selectedRegion = container.querySelector('select[name="region"]').value;

    // 연도 또는 지역 선택이 없을 경우
    if (!selectedRegion || selectedRegion === '' || selectedYears.length === 0) {
        canvas.classList.add('blur');
        overlay.textContent = '지역,연도를 선택해주세요.';
        overlay.classList.add('show');
        if (usageChart) {
            usageChart.destroy();
            usageChart = null;
        }
        return;
    }

    // 차트 데이터 필터링
    const filteredData = chartData.filter(item =>
        item.region === selectedRegion &&
        selectedYears.includes(String(item.year)) &&
        item.monthlyData &&
        item.monthlyData.some(value => value != null)
    );

    const colors = [
        'rgba(255, 99, 132, 0.5)',
        'rgba(54, 162, 235, 0.5)',
        'rgba(255, 206, 86, 0.5)',
        'rgba(75, 192, 192, 0.5)',
        'rgba(153, 102, 255, 0.5)',
        'rgba(255, 159, 64, 0.5)'
    ];

    const datasets = filteredData.map((item, idx) => ({
        label: item.year + "년 " + item.region,
        data: item.monthlyData,
        backgroundColor: colors[idx % colors.length],
        borderColor: colors[idx % colors.length].replace('0.5', '1'),
        borderWidth: 2,
        type: chartType,
        fill: chartType === 'line' ? false : true,
        tension: 0.3
    }));

    if (usageChart) usageChart.destroy();

    // 데이터 없음 처리
    if (datasets.length === 0) {
        canvas.classList.add('blur');
        overlay.textContent = '실제 전력 사용량이 없습니다.';
        overlay.classList.add('show');
        usageChart = null;
        return;
    } else {
        canvas.classList.remove('blur');
        overlay.classList.remove('show');
    }

    const ctx = canvas.getContext('2d');
    usageChart = new Chart(ctx, {
        type: chartType,
        data: {
            labels: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
            datasets: datasets
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: '월별 전력 사용량'
                },
                legend: {
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: '사용량 (GWh)'
                    }
                }
            }
        }
    });
}




//=========================
//단기 예측 데이터 요청 및 차트 그리기
//=========================

//단기 예측 API 호출 (한 해, 지역, 실제 데이터 기반)
async function fetchShortTermPrediction(year, region, actualMonthlyData) {
const cityEncoded = cityEncodeMap[region] ?? 0;
const preds = [];

for (let month = 1; month <= 12; month++) {
 const prevYear = year - 1;
 const key = prevYear + "_" + region;
 let prev_usage = allDataMap[key]
   ? allDataMap[key][month - 1]
   : (month === 1 ? actualMonthlyData[11] : actualMonthlyData[month - 2]);

 const requestBody = {
   city_encoded: cityEncoded,
   year: year - 2014,
   month,
   prev_usage
 };

 try {
   const res = await fetch('http://localhost:8000/model/short', {
     method: 'POST',
     headers: { 'Content-Type': 'application/json' },
     body: JSON.stringify(requestBody)
   });
   const json = await res.json();
   preds.push(json.prediction);
 } catch (e) {
   console.error(`[단기예측 오류] ${region} ${year} ${month}`, e);
   preds.push(null);
 }
}

return preds;
}

//단기 예측 차트 그리기 함수 (API 호출 포함)
async function drawPredictedUsageChart(chartData) {
const selectedYears = Array.from(document.querySelectorAll('input[name="years"]:checked')).map(input => input.value);
const selectedRegion = document.querySelector('select[name="region"]').value;

const canvas = document.getElementById('predictedChart');
const predictedContainer = canvas.parentElement;
const overlayId = 'predictedChartOverlay';
let overlay = document.getElementById(overlayId);

if (!overlay) {
 overlay = document.createElement('div');
 overlay.id = overlayId;
 overlay.className = 'chart-overlay';
 predictedContainer.appendChild(overlay);
}

if (!selectedRegion || selectedRegion === "" || selectedYears.length === 0) {
 overlay.textContent = '지역,연도를 선택해주세요.';
 overlay.classList.add('show');
 canvas.classList.add('blur');
 if (predictedChart) {
   predictedChart.destroy();
   predictedChart = null;
 }
 return;
}

// 2026년 3월까지 예측 가능 체크
if (selectedYears.some(year => Number(year) > 2027) || selectedYears.includes('2027')) {
 overlay.textContent = '2026년 3월까지 예측이 가능합니다.';
 overlay.classList.add('show');
 canvas.classList.add('blur');
 if (predictedChart) {
   predictedChart.destroy();
   predictedChart = null;
 }
 return;
}

overlay.classList.remove('show');
canvas.classList.remove('blur');

const yearSet = new Set(), regionSet = new Set();
chartData.forEach(d => {
 yearSet.add(String(d.year));
 regionSet.add(d.region);
});

const years = Array.from(yearSet).sort();
const regions = Array.from(regionSet).sort();
const datasets = [];
const predictionPromises = [];

function findActualData(region, year) {
 return chartData.find(d => d.region === region && String(d.year) === String(year));
}

regions.forEach(region => {
 years.forEach(year => {
   const actualDataObj = findActualData(region, year);
   if (!actualDataObj) return;

   predictionPromises.push(
     fetchShortTermPrediction(Number(year), region, actualDataObj.monthlyData)
       .then(predictedArray => ({
         year,
         region,
         predictedArray,
         actualData: actualDataObj.monthlyData
       }))
   );
 });
});

const allPredictions = await Promise.all(predictionPromises);

const colors = ['rgba(255, 99, 132)', 'rgba(54, 162, 235)', 'rgba(255, 206, 86)'];
const labels = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];

allPredictions.forEach((pred, idx) => {
 const labelPrefix = pred.year + "년 " + pred.region;

 datasets.push({
   label: labelPrefix + " 예측",
   data: pred.predictedArray,
   backgroundColor: colors[idx % colors.length],
   borderColor: colors[idx % colors.length].replace('0.7', '1'),
   borderWidth: 2,
   type: 'line',
   fill: false,
   tension: 0.3,
   pointRadius: 3,
   pointHoverRadius: 6,
 });

 datasets.push({
   label: labelPrefix + " 실제",
   data: pred.actualData,
   backgroundColor: colors[idx % colors.length].replace('0.7', '0.3'),
   borderColor: colors[idx % colors.length].replace('0.7', '0.5'),
   borderWidth: 1,
   type: 'bar',
   barPercentage: 0.4,
   categoryPercentage: 0.5,
 });
});

const ctx = canvas.getContext('2d');
if (predictedChart) predictedChart.destroy();
predictedChart = new Chart(ctx, {
 type: 'bar',
 data: { labels, datasets },
 options: {
   responsive: true,
   maintainAspectRatio: false,
   plugins: {
     title: { display: true, text: '단기 예측 사용량 vs 실제 사용량' },
     legend: { position: 'top' }
   },
   scales: {
     y: {
       title: { display: true, text: '사용량 (gWh)' }
     }
   }
 }
});
}



//=========================
//장기 예측 데이터 요청 및 차트 그리기
//=========================

//장기 예측 API 호출 (한 해, 지역, 실제 데이터 기반)
async function fetchLongTermPrediction(year, region, actualMonthlyData) {
const cityEncoded = cityEncodeMap[region] ?? 0;
const preds = [];

for (let month = 1; month <= 12; month++) {
 const prevYear = year - 1;
 const key = prevYear + "_" + region;
 let prev_usage = null;

 if (allDataMap[key]) {
   prev_usage = allDataMap[key][month - 1];
 } else {
   prev_usage = month === 1 ? actualMonthlyData[11] : actualMonthlyData[month - 2];
 }

 const requestBody = {
   city_encoded: cityEncoded,
   year: year,
   month,
   prev_usage
 };

 try {
   const res = await fetch('http://localhost:8000/model/long', {
     method: 'POST',
     headers: { 'Content-Type': 'application/json' },
     body: JSON.stringify(requestBody)
   });
   if (!res.ok) {
     console.error('HTTP error:', res.status);
     preds.push(null);
     continue;
   }
   const json = await res.json();
   preds.push(json.prediction);
 } catch (e) {
   console.error(`[장기예측 오류] ${region} ${year} ${month}`, e);
   preds.push(null);
 }
}
return preds;
}

//장기 예측 차트 그리기 함수 (API 호출 포함)
async function drawLongTermUsageChart(chartData) {
const selectedYears = Array.from(document.querySelectorAll('input[name="years"]:checked')).map(input => input.value);
const selectedRegion = document.querySelector('select[name="region"]').value;

const canvas = document.getElementById('longTermChart');
const chartContainer = canvas.parentElement;
const overlayId = 'longTermChartOverlay';
let overlay = document.getElementById(overlayId);

if (!overlay) {
 overlay = document.createElement('div');
 overlay.id = overlayId;
 overlay.className = 'chart-overlay';
 chartContainer.appendChild(overlay);
}

if (!selectedRegion || selectedRegion === "" || selectedYears.length === 0) {
 overlay.textContent = '지역,연도를 선택해주세요.';
 overlay.classList.add('show');
 canvas.classList.add('blur');
 if (longTermChart) {
   longTermChart.destroy();
   longTermChart = null;
 }
 return;
}

overlay.classList.remove('show');
canvas.classList.remove('blur');

const yearSet = new Set(), regionSet = new Set();
chartData.forEach(d => {
 yearSet.add(String(d.year));
 regionSet.add(d.region);
});

const years = Array.from(yearSet).sort();
const regions = Array.from(regionSet).sort();
const filteredRegions = selectedRegion === 'all' ? regions : [selectedRegion];
const filteredYears = selectedYears;

const predictionPromises = [];

function findActualData(region, year) {
 return chartData.find(d => d.region === region && String(d.year) === String(year));
}

filteredRegions.forEach(region => {
 filteredYears.forEach(year => {
   const actualDataObj = findActualData(region, year);
   if (!actualDataObj) return;

   predictionPromises.push(
     fetchLongTermPrediction(Number(year), region, actualDataObj.monthlyData)
       .then(predictedArray => ({
         year,
         region,
         predictedArray,
         actualData: actualDataObj.monthlyData
       }))
   );
 });
});

const allPredictions = await Promise.all(predictionPromises);

const colors = ['rgba(75, 192, 192)', 'rgba(153, 102, 255)', 'rgba(255, 159, 64)'];
const datasets = [];

const labels = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];

allPredictions.forEach((pred, idx) => {
 const labelPrefix = pred.year + "년 " + pred.region;

 datasets.push({
   label: labelPrefix + " 예측",
   data: pred.predictedArray,
   backgroundColor: colors[idx % colors.length],
   borderColor: colors[idx % colors.length].replace('0.7', '1'),
   borderWidth: 2,
   type: 'line',
   fill: false,
   tension: 0.3,
   pointRadius: 3,
   pointHoverRadius: 6,
 });

 datasets.push({
   label: labelPrefix + " 실제",
   data: pred.actualData,
   backgroundColor: colors[idx % colors.length].replace('0.7', '0.3'),
   borderColor: colors[idx % colors.length].replace('0.7', '0.5'),
   borderWidth: 1,
   type: 'bar',
   barPercentage: 0.4,
   categoryPercentage: 0.5,
 });
});

const ctx = canvas.getContext('2d');
if (longTermChart) longTermChart.destroy();
longTermChart = new Chart(ctx, {
 type: 'bar',
 data: {
   labels,
   datasets
 },
 options: {
   responsive: true,
   maintainAspectRatio: false,
   plugins: {
     title: { display: true, text: '장기 예측 사용량 vs 실제 사용량' },
     legend: { position: 'top' }
   },
   scales: {
     y: {
       title: { display: true, text: '사용량 (gWh)' }
     }
   }
 }
});
}
//페이지 초기화 함수 - 서버에서 받은 데이터(chartData)를 인자로 받음
async function init(chartData) {
    drawActualUsageChart(chartData);           // 실제 사용량 차트
    await drawPredictedUsageChart(chartData);  // 단기 예측 차트
    await drawLongTermUsageChart(chartData);   // 장기 예측 차트
}

// DOM 준비 시 실행 (jQuery 방식)
// window.onload와 중복 피하기 위해 이쪽만 사용
$(function() {
    const $multiSelect = $('.multi-select');
    const $selectBox = $multiSelect.find('.select-box');
    const $checkboxList = $multiSelect.find('.checkbox-list');

    // select-box 클릭 시 체크박스 리스트 토글
    $selectBox.on('click', function(e) {
        e.stopPropagation();
        $checkboxList.toggleClass('expanded');
    });

    $checkboxList.on('click', function(e) {
        e.stopPropagation();
    });

    // 체크박스 상태 변경 시 선택된 연도 목록 업데이트
    $checkboxList.find('input[type=checkbox]').on('change', function() {
        const selected = [];
        $checkboxList.find('input[type=checkbox]:checked').each(function() {
            selected.push($(this).val());
        });
        if (selected.length) {
            $selectBox.text(selected.join(', ') + '년');
        } else {
            $selectBox.text('연도 선택');
        }
    });

    // 외부 클릭 시 드롭다운 닫기
    $(document).on('click', function() {
        if ($checkboxList.hasClass('expanded')) {
            $checkboxList.removeClass('expanded');
        }
    });

    // 키보드 접근성: Escape 또는 Tab 키로 드롭다운 닫기
    $multiSelect.on('keydown', function(e) {
        if (e.key === 'Escape' || e.key === 'Tab') {
            if ($checkboxList.hasClass('expanded')) {
                $checkboxList.removeClass('expanded');
            }
        }
    });

    // 페이지 로드 시 선택된 항목 텍스트 반영
    const initSelected = [];
    $checkboxList.find('input[type=checkbox]:checked').each(function() {
        initSelected.push($(this).val());
    });
    if (initSelected.length) {
        $selectBox.text(initSelected.join(', ') + '년');
    } else {
        $selectBox.text('연도 선택');
    }

    // 그래프 다운로드 버튼 이벤트
    document.getElementById('downloadBtn').addEventListener('click', () => {
        const selected = document.getElementById('graphToggle').value;
        const usageCanvas = document.getElementById('usageChart');
        const isUsageBlurred = usageCanvas.classList.contains('blur'); // 수정: classList로 체크

        switch(selected) {
            case 'usage':
                if (isUsageBlurred) {
                    alert('실제 사용량 그래프가 블러 처리 되어 다운로드할 수 없습니다.');
                    return;
                }
                if (usageChart) {
                    const url = usageChart.toBase64Image();
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = '실제_전력_사용량.png';
                    a.click();
                } else {
                    alert('실제 전력 사용량 그래프가 없습니다.');
                }
                break;

            case 'predicted':
                if (!predictedChart && !longTermChart) {
                    alert('예측 그래프가 없습니다.');
                    return;
                }
                if (predictedChart) {
                    const url = predictedChart.toBase64Image();
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = '단기_예측_전력_사용량.png';
                    a.click();
                }
                if (longTermChart) {
                    const url = longTermChart.toBase64Image();
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = '장기_예측_전력_사용량.png';
                    a.click();
                }
                break;

            case 'predicted_short':
                if (predictedChart) {
                    const url = predictedChart.toBase64Image();
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = '단기_예측_전력_사용량.png';
                    a.click();
                } else {
                    alert('단기 예측 그래프가 없습니다.');
                }
                break;

            case 'predicted_long':
                if (longTermChart) {
                    const url = longTermChart.toBase64Image();
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = '장기_예측_전력_사용량.png';
                    a.click();
                } else {
                    alert('장기 예측 그래프가 없습니다.');
                }
                break;

            case 'both':
                if (!isUsageBlurred && usageChart) {
                    const url = usageChart.toBase64Image();
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = '실제_전력_사용량.png';
                    a.click();
                }
                if (predictedChart) {
                    const url = predictedChart.toBase64Image();
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = '단기_예측_전력_사용량.png';
                    a.click();
                }
                if (longTermChart) {
                    const url = longTermChart.toBase64Image();
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = '장기_예측_전력_사용량.png';
                    a.click();
                }
                break;
        }
    });

    // 검색 폼 제출 이벤트
$('#searchForm').on('submit', async function(e) {
    e.preventDefault();

    const $regionSelect = $('select[name="region"]');
    const selectedRegion = $regionSelect.val();
    const $checkedYears = $('input[name="years"]:checked');

    if (!selectedRegion || selectedRegion === '') {
        alert('지역을 선택해주세요.');
        $regionSelect.focus();
        return;
    }

    if ($checkedYears.length === 0) {
        alert('최소 1개 이상의 연도를 선택해주세요.');
        return;
    }

    const selectedYears = $checkedYears.map(function() {
        return this.value;
    }).get();

    const params = new URLSearchParams();
    selectedYears.forEach(function(y) {
        params.append('years', y);
    });
    params.append('region', selectedRegion);

    try {
        const data = await $.ajax({
            url: '/usageChart/chart?' + params.toString(),
            method: 'GET',
            dataType: 'json'
        });

        // 전역 변수에 데이터 저장
        globalChartData = data.chartData;

        // 차트 그리기
        drawActualUsageChart(globalChartData);
        await drawPredictedUsageChart(globalChartData);
        await drawLongTermUsageChart(globalChartData);

        if (typeof updateSelectedInfo === 'function') {
            updateSelectedInfo(data.selectedYears, data.selectedRegion);
        }
    } catch (error) {
        console.error('데이터 요청 실패:', error);
    }
});


    // 선택된 연도, 지역 화면에 표시
    function updateSelectedInfo(years, region) {
        const yearsElem = document.getElementById('selectedYearsDisplay');
        const regionElem = document.getElementById('selectedRegionDisplay');

        if (!years || years.length === 0) {
            yearsElem.innerHTML = '<strong>선택한 연도:</strong> 연도가 선택되지 않았습니다.';
        } else {
            yearsElem.innerHTML = '<strong>선택한 연도:</strong> ' + years.join(', ') + '년';
        }

        if (!region || region.trim() === '') {
            regionElem.innerHTML = '<strong>선택한 지역:</strong> 선택한 지역이 없습니다.';
        } else if (region === 'all') {
            regionElem.innerHTML = '<strong>선택한 지역:</strong> 전체';
        } else {
            regionElem.innerHTML = '<strong>선택한 지역:</strong> ' + region;
        }
    }
});

</script>

<script>
    window.addEventListener('DOMContentLoaded', async () => {
        // 초기 빈 데이터로 차트 초기화
        drawActualUsageChart([]);              // 실제 사용량 차트
        await drawPredictedUsageChart([]);     // 단기 예측 차트
        await drawLongTermUsageChart([]);      // 장기 예측 차트
    });
</script>

</body>
</html>
