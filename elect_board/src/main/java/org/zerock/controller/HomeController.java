package org.zerock.controller;

import java.text.DateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.zerock.domain.GraphmapVO;
import org.zerock.mapper.GraphmapMapper;

/**
 * Handles requests for the application home page.
 */
@Controller
public class HomeController {
	
private static final Logger logger = LoggerFactory.getLogger(HomeController.class);
	
	@Autowired
	private GraphmapMapper graphmapMapper;

	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String home(Locale locale, Model model) {
		logger.info("Welcome home! The client locale is {}.", locale);
		
		// 날짜 출력용
		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);
		String formattedDate = dateFormat.format(date);
		model.addAttribute("serverTime", formattedDate );

		// 💡 전력 사용량 데이터 조회
		List<GraphmapVO> dataList = graphmapMapper.view();

		if (!dataList.isEmpty()) {
			GraphmapVO selected = dataList.get(0); // 첫 번째 지역 선택

			model.addAttribute("region", selected.getRegion());
			model.addAttribute("year", selected.getYear());
			model.addAttribute("monthlyUsage", List.of(
				selected.getMonth1(), selected.getMonth2(), selected.getMonth3(),
				selected.getMonth4(), selected.getMonth5(), selected.getMonth6(),
				selected.getMonth7(), selected.getMonth8(), selected.getMonth9(),
				selected.getMonth10(), selected.getMonth11(), selected.getMonth12()
			));
		}

		return "home"; // /WEB-INF/views/home.jsp
	}
}
