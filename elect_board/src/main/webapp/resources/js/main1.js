	$(document).ready(function(){
		let today = new Date();
	    let year = today.getFullYear();
	    let month = today.getMonth() + 1;
	    let nowMonthAll = 0.00; // 이번달 전력사용량 총합
	    let nextMonthAll = 0.00; // 다음달 전력사용량 총합
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
	        let menus = $('.menu').not('#month'); // '전체' 제외

	        for (let i = 0; i < menus.length; i++) {
	            let $this = $(menus[i]);
	            try {
	                let prediction = await predictAndReturnCorrect($this, year, month);
	                $this.find('p').text(prediction + ' GWh');
	            } catch (error) {
	                $this.find('p').text(error); // '예측 오류' 또는 '도시코드 없음'
	            }
	        }
	    }
	    // 호출
	    setPredictionToMenu();
	    
	    // 이번달 전력 사용량 총합
		async function thisMonthTotalUsage() {
    		let menus = $('.menu').not('#month');
   			let requestList = menus.map(function() {
        		let $this = $(this);
        		let cityCode = $this.data('citycode');
        		return getPreviousUsagePromise($this, year - 1, month)
            		.then(prevUsage => {
                		return {
                    		city_encoded: cityCode,
                    		year: year - 2014,
                    		month: month,
                    		prev_usage: prevUsage
                		};
            		});
    		}).get();

    		let requests = await Promise.all(requestList); // 전년도 사용량까지 모두 해결됨

    		let response = await $.ajax({
        		url: '/modelShortBatch',
      		  	method: 'POST',
    		    contentType: 'application/json',
        		data: JSON.stringify({ requests: requests })
    		});

    		// FastAPI가 돌려준 predictions 사용
    		nowMonthAll = Object.values(response.predictions).reduce((sum, val) => sum + val, 0);
		}

		// 다음달 전력 사용량 총합 (배치 요청 버전)
		async function nextMonthTotalUsage() {
		    let menus = $('.menu').not('#month');
		    let requestList = menus.map(function() {
		        let $this = $(this);
		        let cityCode = $this.data('citycode');
		        return getPreviousUsagePromise($this, year - 1, month + 1)  // 전년도 다음달 사용량
		            .then(prevUsage => {
		                return {
		                    city_encoded: cityCode,
		                    year: year - 2014,
		                    month: month + 1,
		                    prev_usage: prevUsage
		                };
		            });
		    }).get();

		    let requests = await Promise.all(requestList);

		    let response = await $.ajax({
		        url: '/modelShortBatch',
		        method: 'POST',
		        contentType: 'application/json',
		        data: JSON.stringify({ requests: requests })
		    });

		    nextMonthAll = Object.values(response.predictions).reduce((sum, val) => sum + val, 0);
		}

	    
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
	        let promises = [];

	        for (let i = 4; i >= 1; i--) {
	            let yearToFetch = thisYear - i; // 4년 전부터 1년 전까지
	            promises.push(getPreviousUsagePromise($element, yearToFetch, month));
	        }

	        try {
	            let usageArray = await Promise.all(promises);
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
		    let cityCode = $element.data('citycode');
		    if (cityCode === undefined) throw '도시코드 없음';

		    try {
		        let prevUsage = await getPreviousUsagePromise($element, year - 1, month); // 전년도 값
		        let prediction = await $.ajax({
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
	 	
		// 단기 예보 호출
		function fetchWeatherForClickedMenu($clickedMenu) {
		  var selectedCityCode = $clickedMenu.data('citycode');
		  var currentDate = new Date();
		  var currentYear = currentDate.getFullYear();
		  var currentMonth = (currentDate.getMonth() + 1);
		  if (currentMonth < 10) currentMonth = '0' + currentMonth;
		  var currentDay = currentDate.getDate();
		  if (currentDay < 10) currentDay = '0' + currentDay;
		  var formattedDate = currentYear + '' + currentMonth + '' + currentDay;

		  if (!selectedCityCode || !formattedDate) {
		    console.error("도시코드 또는 날짜가 유효하지 않습니다.");
		    return;
		  }

		  $.ajax({
		    url: '/weather/short',
		    method: 'GET',
		    dataType: 'json',
		    data: {
		      citycode: selectedCityCode,
		      baseDate: formattedDate
		    },
		    success: function(response) {
		      var dayNames = ['일', '월', '화', '수', '목', '금', '토'];

		      for (var i = 0; i < response.length && i < 4; i++) {
		        var item = response[i];
		        var dateObj = new Date(item.date);
		        var month = dateObj.getMonth() + 1;
		        var day = dateObj.getDate();
		        var weekDay = dayNames[dateObj.getDay()];

		        if (month < 10) month = '0' + month;
		        if (day < 10) day = '0' + day;

		        var formattedDateStr = month + '/' + day + ' (' + weekDay + ')';

		        var weatherDesc = (item.precipitation === '없음') ? item.sky : item.precipitation;
		        var emoji = getWeatherEmoji(weatherDesc);

		        var usage = predictUsage(parseInt(item.maxTemperature), weatherDesc, dateObj.getMonth() + 1);

		        var row = $('#day' + (i + 1));
		        row.find('td').eq(0).text(formattedDateStr);
		        row.find('td').eq(1).text(emoji + ' ' + weatherDesc);
		        row.find('td').eq(2).text(item.minTemperature + '℃');
		        row.find('td').eq(3).text(item.maxTemperature + '℃');
		        row.find('td').eq(4).attr('class', usage.cssClass).text(usage.text);
		      }
		    },
		    error: function(xhr, status, error) {
		      console.error('에러 발생:', error);
		      console.log(xhr.responseText);
		    }
		  });
		}
		// 날씨 → 이모지 매핑 함수
		function getWeatherEmoji(desc) {
		  var emojiMap = {
		    '맑음': '☀️',
		    '구름많음': '🌤️',
		    '흐림': '☁️',
		    '비': '🌧️',
		    '비/눈': '🌧️/❄️',
		    '눈': '❄️',
		    '소나기': '🌦️'
		  };
		  return emojiMap[desc] || '❓';
		}
		// 전기사용량 예측 판단 함수 (계절별 적용)
		function predictUsage(maxTemp, weather, month) {
		  var isSummer = (month >= 6 && month <= 8);
		  var isWinter = (month === 12 || month === 1 || month === 2);

		  if (isWinter && weather === '눈') {
		    return { text: '증가 예상 ↑', cssClass: 'increase' };
		  }
		  if (isSummer && maxTemp >= 28) {
		    return { text: '증가 예상 ↑', cssClass: 'increase' };
		  }
		  if (isWinter && maxTemp <= 5) {
		    return { text: '증가 예상 ↑', cssClass: 'increase' };
		  }
		  if (weather === '비') {
		    if (isSummer) {
		      return { text: '감소 예상 ↓', cssClass: 'decrease' };
		    }
		    return { text: '유지 예상 →', cssClass: 'neutral' };
		  }
		  if (maxTemp <= 10) {
		    return { text: '감소 예상 ↓', cssClass: 'decrease' };
		  }
		  if (maxTemp >= 30) {
		    return { text: '증가 예상 ↑', cssClass: 'increase' };
		  }

		  return { text: '유지 예상 →', cssClass: 'neutral' };
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
		    } catch(err) {
		        console.error(err);
		    }
		    
		    // 올해 1월 ~ 12월 데이터 가져오기
		    try {
		        yearAllUsage = await getPrevAllUsagePromise($element, year);
		    } catch(err) {
		        console.error(err);
		    }
		    
		    // 0 또는 null이면 예측 모델 사용
		    for (let i = 0; i < 12; i++) {
		        if (!yearAllUsage[i] || yearAllUsage[i] === 0) {
		            try {
		                let predicted = await predictAndReturnCorrect($element, year, i + 1);
		                yearAllUsage[i] = predicted;
		            } catch (err) {
		                console.error(err);
		            }
		        }
		    }
		    
		    // 4년치 월 사용량 가져오기
		    month4Years = await getPast4YearsJuneUsage($element, year);
		    
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
		                }
		                ,
		          	  	datalabels: {
		                    //display: false
		                    color:'black',
		                    font: { weight: 'bold', size: 12 },
    	        textStrokeColor: 'white',                  // ✅ 테두리 색상
    	        textStrokeWidth: 1                         // ✅ 테두리 두께
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
		                	'rgb(28, 61, 76)',
		                	'rgb(67, 97, 117)',
		                	'rgb(107, 134, 157)',
		                	'rgb(147, 172, 191)',
		                	'rgb(178, 211, 226)',
		                ],
		                borderColor: [
		                	'rgb(28, 61, 76)',
		                	'rgb(67, 97, 117)',
		                	'rgb(107, 134, 157)',
		                	'rgb(147, 172, 191)',
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
		               ,
		          	  	datalabels: {
		                    //display: false
		                    color:'black',
		                    font: { weight: 'bold', size: 12 },
    	        textStrokeColor: 'white',                  // ✅ 테두리 색상
    	        textStrokeWidth: 1                         // ✅ 테두리 두께
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
		    await thisMonthTotalUsage() // 이번달 전력사용량 총합
		    let usageRate = 0;
		    if (nowMonthAll !== 0) { // 0으로 나누기 방지
		        usageRate = (yearAllUsage[month - 1] / nowMonthAll) * 100;
		        usageRate = usageRate.toFixed(2); // 소수 둘째자리까지 반올림
		        console.log("이번달 예측 퍼센트: "+usageRate+"%")
		    } else {
		        usageRate = "0.00"; // 혹시나 전체 사용량이 0일 때 대비
		    }
		    // 원형차트에 글씨넣는 플러그인
		    let centerTextPlugin = {
		    		  id: 'centerText',
		    		  beforeDraw(chart) {
		    		    let ctx = chart.ctx;
		    		    let {top, bottom, left, right} = chart.chartArea;

		    		    ctx.save();

		    		    // 중앙 좌표 계산
		    		    let centerX = (left + right) / 2;
		    		    let centerY = (top + bottom) / 2;

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
		    	    	labels: [month+"월 "+$(this).find('h2').text()+" 전력 사용량", month+"월 전체 시·도 전력 사용량"],
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
		    await nextMonthTotalUsage() // 다음달 전력사용량 총합
		    let nextUsage = await predictAndReturnCorrect($element, year, month + 1);
	        usageRate2 = (nextUsage / nextMonthAll) * 100;
	        usageRate2 = usageRate2.toFixed(2); // 소수 둘째자리까지 반올림
	        console.log("다음달 예측 퍼센트: "+usageRate2+"%")
		    $("#nowH23").text(month+1+"월 사용량 예측");
		    $("#nowH24").text(nextUsage+" GWh");
		    // 원형차트에 글씨넣는 플러그인
		    let centerTextPlugin2 = {
		    		  id: 'centerText',
		    		  beforeDraw(chart) {
		    		    let ctx = chart.ctx;
		    		    let {top, bottom, left, right} = chart.chartArea;

		    		    ctx.save();

		    		    // 중앙 좌표 계산
		    		    let centerX = (left + right) / 2;
		    		    let centerY = (top + bottom) / 2;

		    		    ctx.textAlign = 'center';
		    		    ctx.textBaseline = 'middle';

		    		    ctx.font = 'bold 16px Arial';  // 글꼴, 크기 조정 가능
		    		    ctx.fillStyle = 'white';        // 글씨 색상

		    		    ctx.fillText(region, centerX, centerY - 10);
		    		    ctx.fillText(" "+usageRate2+"%", centerX, centerY + 10);

		    		    ctx.restore();
		    		  }
		    };
			// 차트 지우기
		    if (Chart5) {
		        Chart5.destroy();
		    }
		    let nextUsageChart = $('#nextUsageChart')[0].getContext('2d');
		    Chart5 = new Chart(nextUsageChart, {
		    	  type: 'doughnut',
		    	    data: {
		    	    	labels: [month+1+"월 "+$(this).find('h2').text()+" 전력 사용량", month+1+"월 전체 시·도 전력 사용량"],
		    	      	datasets: [{
			    	        data: [nextUsage, nextMonthAll],
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
		   		plugins: [centerTextPlugin2]
		    });
		    fetchWeatherForClickedMenu($(this));
		});
		// 사이트 로드시 서울정보 가져오기
		$("#seoul").click();
	});