<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
    
<!-- header 관련 스타일 html js만 따로 뺀 거 -->


<style>
body {
	z-index:0;
	overflow: hidden; /*스크롤 막는 거*/
}
header{
    display: flex;
    position: fixed;
   	right: 0;
    top: 0;
    z-index: 1000;
    height: 100vh;
    width:13vw;
    background: linear-gradient(to bottom, rgb(93, 93, 115), rgb(149, 149, 182));


}
.header-table{
height:300px;
width:11vw;
margin:0 auto;
}
.current_class{
    color:orange;
    font-weight: bold;
}

.navi{
    cursor: default;
	margin:auto;
align-items: center;         /* 가로 중앙 정렬 */
justify-content: center;     /* 세로 중앙 정렬 */
text-align: center;          /* 텍스트 가운데 정렬 */
}
a{
text-decoration:none;
}
a:hover{
text-decoration:none;
}
a:visited{
text-decoration:none;
}
a:active{
text-decoration:none;
}
div {
	box-sizing: border-box;
}
.pagediv{
min-width: 100vw;
min-height: 100vh;
position: relative;
display: inline-block;
margin:0;
}
#two{
border-bottom:2px solid darkblue;

</style>
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
	    if ($root.is(':animated')) return;        // 애니메이션 중엔 무시

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