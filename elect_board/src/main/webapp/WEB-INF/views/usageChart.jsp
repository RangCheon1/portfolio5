<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>전력 사용량 비교</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* 동일한 스타일 유지 */
        body {
            font-family: 'Segoe UI', sans-serif;
            font-size: 16px;
            color: #222;
            margin: 20px;
        }
        .container {
            max-width: 1000px;
            margin: auto;
        }
        canvas {
            width: 100% !important;
            max-width: 100%;
            height: 400px !important;
            display: block;
            margin: 20px 0;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .checkbox-group {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }
        .checkbox-item {
            display: flex;
            align-items: center;
            gap: 4px;
            padding: 6px 10px;
            background-color: #f0f0f0;
            border-radius: 5px;
            font-size: 15px;
            cursor: pointer;
        }
        .checkbox-item:hover {
            background-color: #e0e0e0;
        }
        select, input[type="submit"], input[type="number"], button {
            padding: 8px 12px;
            font-size: 15px;
            margin-right: 5px;
        }
        h3 {
            margin-top: 40px;
            font-size: 20px;
        }
    </style>
</head>
<body>
<div class="container">

    <form method="get" action="/usageChart">
        <div class="form-group">
            <label>연도 선택 (복수 선택 가능):</label>
            <div class="checkbox-group">
                <c:forEach var="y" begin="2014" end="2025">
                    <label class="checkbox-item">
                        <input type="checkbox" name="years" value="${y}"
                               <c:if test="${selectedYears != null and selectedYears.contains(y.toString())}">checked</c:if> />
                        ${y}년
                    </label>
                </c:forEach>
            </div>
        </div>

        <div class="form-group">
            <label>지역 선택:</label>
            <select name="region" size="1">
                <option value="all" <c:if test="${selectedRegion == 'all'}">selected</c:if>>전체</option>
                <c:forEach var="r" items="${regionList}">
                    <option value="${r}" <c:if test="${selectedRegion == r}">selected</c:if>>${r}</option>
                </c:forEach>
            </select>
        </div>

        <div class="form-group">
            <input type="submit" value="조회" />
        </div>
    </form>

    <h3>월별 전력 사용량</h3>
    <canvas id="usageChart"></canvas>

    <h3>단기 예측 전력 사용량 (실제 사용량 포함)</h3>
    <canvas id="predictedChart"></canvas>

</div>

<script>
    const chartData = JSON.parse('${chartDataJson}');
    
    console.log('Chart Data:', chartData);
    
    const labels = ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'];

    const cityEncodeMap = {
        "Seoul": 0,
        "Busan": 1,
        "Incheon": 2,
        "all": -1
    };

    function drawActualUsageChart() {
        const colors = [
            'rgba(255, 99, 132, 0.5)',
            'rgba(54, 162, 235, 0.5)',
            'rgba(255, 206, 86, 0.5)',
            'rgba(75, 192, 192, 0.5)',
            'rgba(153, 102, 255, 0.5)',
            'rgba(255, 159, 64, 0.5)',
            'rgba(100, 200, 100, 0.5)',
            'rgba(200, 100, 255, 0.5)',
            'rgba(255, 120, 180, 0.5)',
            'rgba(120, 120, 255, 0.5)'
        ];

        const datasets = chartData.map((item, idx) => ({
            label: item.year + '년 ' + item.region,
            data: item.monthlyData,
            backgroundColor: colors[idx % colors.length],
            type: 'bar'
        }));

        const ctx = document.getElementById('usageChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: { labels: labels, datasets: datasets },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                aspectRatio: 2,
                plugins: {
                    title: {
                        display: true,
                        text: '연도별 월별 전력 사용량',
                        font: { size: 18 }
                    },
                    legend: {
                        position: 'bottom',
                        labels: { font: { size: 14 } }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: { display: true, text: '사용량 (kWh)', font: { size: 16 } },
                        ticks: { font: { size: 14 } }
                    },
                    x: { ticks: { font: { size: 14 } } }
                }
            }
        });
    }

    async function fetchShortTermPrediction(year, region, actualMonthlyData) {
        const cityEncoded = cityEncodeMap[region] !== undefined ? cityEncodeMap[region] : 0;
        const preds = [];

        for(let month=1; month<=12; month++) {
            const prev_usage = month === 1 ? 0 : actualMonthlyData[month-2];
            const requestBody = { city_encoded: cityEncoded, year: year, month: month, prev_usage: prev_usage };

            try {
                const res = await fetch('http://localhost:8000/model/short', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(requestBody)
                });
                const json = await res.json();
                preds.push(json.prediction);
            } catch (e) {
                console.error(`예측 API 오류 [${region} ${year} ${month}]:`, e);
                preds.push(null);
            }
        }
        return preds;
    }

    async function drawPredictedUsageChart() {
        if(chartData.length === 0) return;

        const yearSet = new Set();
        const regionSet = new Set();
        chartData.forEach(d => {
            yearSet.add(String(d.year));
            regionSet.add(d.region);
        });

        const years = Array.from(yearSet).sort();
        const regions = Array.from(regionSet).sort();
        const datasets = [];

        function findActualData(region, year) {
            return chartData.find(d => d.region === region && String(d.year) === String(year));
        }

        const predictionPromises = [];

        regions.forEach(region => {
            years.forEach(year => {
                const actualDataObj = findActualData(region, year);
                if(!actualDataObj) return;

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

        const colors = [
            'rgba(255, 99, 132, 0.7)',
            'rgba(54, 162, 235, 0.7)',
            'rgba(255, 206, 86, 0.7)',
            'rgba(75, 192, 192, 0.7)',
            'rgba(153, 102, 255, 0.7)',
            'rgba(255, 159, 64, 0.7)',
            'rgba(100, 200, 100, 0.7)',
            'rgba(200, 100, 255, 0.7)',
            'rgba(255, 120, 180, 0.7)',
            'rgba(120, 120, 255, 0.7)'
        ];

        allPredictions.forEach((pred, idx) => {
            const labelPrefix = pred.year+"년"+pred.region
            
            console.log(labelPrefix);
            
            datasets.push({
                label: labelPrefix+ "예측",
                data: pred.predictedArray,
                backgroundColor: colors[idx % colors.length],
                borderColor: colors[idx % colors.length].replace('0.7', '1'),
                borderWidth: 1,
                type: 'bar',
                barPercentage: 0.4,
                categoryPercentage: 0.5,
            });

            datasets.push({
                label: labelPrefix + "실제",
                data: pred.actualData,
                backgroundColor: colors[idx % colors.length].replace('0.7', '0.3'),
                borderColor: colors[idx % colors.length].replace('0.7', '0.5'),
                borderWidth: 1,
                type: 'bar',
                barPercentage: 0.4,
                categoryPercentage: 0.5,
            });
        });

        const ctx = document.getElementById('predictedChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: { labels: labels, datasets: datasets },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                aspectRatio: 2,
                plugins: {
                    title: {
                        display: true,
                        text: '단기 예측 전력 사용량 (실제 사용량 포함)',
                        font: { size: 18 }
                    },
                    legend: {
                        display: true,
                        position: 'bottom',
                        labels: { font: { size: 14 } }
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        callbacks: {
                            title: function(context) {
                                return context[0].label;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: { display: true, text: '사용량 (kWh)', font: { size: 16 } },
                        ticks: { font: { size: 14 } }
                    },
                    x: {
                        ticks: { font: { size: 14 } },
                        stacked: false
                    }
                }
            }
        });
    }

    drawActualUsageChart();
    drawPredictedUsageChart();
</script>
</body>
</html>
