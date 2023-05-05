
//#include "def.h"

#include "utils/maths.h"
#include "utils/worldmodel.h"
#include "utils/PlayerTask.h"

#pragma comment(lib, "worldmodel_lib.lib")

//用户注意；接口需要如下声明
extern "C" _declspec(dllexport) PlayerTask player_plan(const WorldModel *model, int robot_id); //绿色部分为声明函数 player_plan


/*
1. 足球机器人长度 角度坐标系 是 atanf2 , （-PI, PI],
2. X轴正方向为 中点->对方球门的位置， 顺时针转动 90°，为y轴正方向
*/

/* 自定义函数 */
float my_limite(float x, float max, float min);//限定大小阈值
float atan2fCorrect(float dir);//atan2f 超越PI 与 -PI  时重新更新
float DIR(float d);/*atan2f  角度 转化为 【0 ， 2 PI】 角度*/
int GetReceverID(const WorldModel *model, int robot_id);/*获取我方接球队员 ID*/
float RunOnCircleDir(float b2r, float b2g, float DetAngle);/*绕圆周 转动时 每次转移时调整的 弧度/角度 || 参数：  球->球员， 球->目标点  旋转弧度*/
float RunToCircleDir(float b2r, float b2g);/* 跑向圆周时 应该到达的 位置角度值 ||参数：  球->球员， 球->目标点  */
float Reverse_Dir(float dir);			   // atanf2 角度反转
// float SetKickPower(float dist， param..... param... ); // 根据距离 等 综合出 合适的 传球力度


int GetOppGoalieID(const WorldModel *model, int robot_id);
const point2f GetOppGoaliePos(const WorldModel *model, int robot_id);
const float KickDir(point2f goalpos, point2f ballpos, point2f oppGoaliePos);
//获取对面守门球员 ID序号
int GetOppGoalieID(const WorldModel *model, int robot_id){
	int  oppGoalieID = -100;

	oppGoalieID = model->get_opp_goalie();

	if (oppGoalieID >= 1 && oppGoalieID <= 12){
		return oppGoalieID;
	}
	else{
		return  -100; //wrong  没有守门员
	}
}
//获取对面守门球员位置
const point2f GetOppGoaliePos(const WorldModel *model, int robot_id){
	point2f oppGoaliePos = { 300, 0 };
	int oppGoalieID = GetOppGoalieID(model, robot_id);
	if (oppGoalieID != -100){
		oppGoaliePos = model->get_opp_player_pos(oppGoalieID);
	}
	return oppGoaliePos;
}

const float KickDir(point2f goalpos, point2f ballpos, point2f oppGoaliePos){
	//根据球的位置判定偏向
	goalpos.y = ballpos.y > 0 ? abs(goalpos.y) : -abs(goalpos.y);

	//根据守门员判定偏向
	if (oppGoaliePos.x != 300 && oppGoaliePos.y != 0)
	{
		if (oppGoaliePos.y >= 0)
		{
			goalpos.y = -abs(goalpos.y);
		}
	}
	return  DIR((goalpos - ballpos).angle()); //射门方向
}
/*
需要更改

//传球力度
int my_kick_power;

*/

 
#define mode  KICK_my

//  射门
PlayerTask player_plan(const WorldModel *model, int robot_id)
{
	PlayerTask task;

	

	int my_kick_power; //传球力度
	
	const point2f &ball = model->get_ball_pos(); //足球坐标
	point2f goal; 		//目标点坐标  可以是 球门 也可以是 某个队员， 但是传球力度需要 精调整
	point2f gatePos(300, 25); //球门假象坐标
	//gatePos.y = ball.y > 0 ? gatePos.y : -gatePos.y;
	goal = gatePos;//目标点坐标
	printf("地方守门员ID--==**//== %d\n", GetOppGoalieID(model, robot_id));

	point2f oppGoaliePos = GetOppGoaliePos(model, robot_id);
	const float toGoalDir = KickDir(goal, ball, oppGoaliePos); //足球到目标的方向
	const float toGoalDist = (goal - ball).length();	//足球到目标点的距离
	my_kick_power = 80;   // 射门的话 看比赛要求， 看看是否限制了踢球力度，
	


	static int i = 0; //静态标志 确认 踢球角度及状态

	static int nearBall = false; //接近placePos？

	static bool isGetBall = false; //是否得到球了

	static const float circleR = 35; //绕行调整半径

	const point2f &playerPos = model->get_our_player_pos(robot_id); //球员坐标

	const float &robot_dir = model->get_our_player_dir(robot_id); //球员朝向

	float g2b = DIR((ball - goal).angle());//目标到球的方向

	float b2g = DIR(Reverse_Dir(g2b));//球到目标的方向

	float r2b = DIR((ball - playerPos).angle());//队员朝向足球的方向

	float b2r = DIR((playerPos - ball).angle()); //足球朝向队员的方向

	float toBallDist = DIR((playerPos - ball).length());//球员到足球的距离


	/*
	获取对面人员信息
	*/

	const point2f &firstPos = ball + Maths::vector2polar(circleR - 2, b2r);//远距离 应该达到圆周上的位置

	const point2f &placePos = ball - Maths::vector2polar(circleR - 2, toGoalDir);//圆周上 适合切入 kickPos的位置
	float toPlaceposDist = (playerPos - placePos).length();//到切入点距离 

	const point2f &kickPos = ball - Maths::vector2polar(MAX_ROBOT_SIZE - 2, toGoalDir);//射门 应该达到的 kickPos

	float toKickPosDist = (playerPos - kickPos).length();//到射门点 距离


	if (toBallDist > circleR) //距离未到达足够近, 车向球靠近 去往 直线距离圆周上最近的一点
	{
		if (ball.X() < 300 && ball.X() > -300 && ball.Y() < 200 && ball.Y() > -200) //球在图像中时，保存球的位置
		{
			//车跑向球

			/*精调整 细节*/
			task.orientate = b2r + PI;
			task.target_pos = ball + Maths::vector2polar(circleR - 1, RunToCircleDir(b2r, b2g));

			/*粗略*/
			/*task.orientate = r2b;
			task.target_pos = firstPos;*/
		}
	}

	/* 绕圆周 不断逼近 placePos */
	else if (toBallDist < circleR + 5 && toBallDist > circleR - 12)
	{
		task.target_pos = ball + Maths::vector2polar(circleR - 3, RunOnCircleDir(b2r, b2g, PI / 5)); // +顺时针 || -逆时针 
		task.orientate = r2b;

		if (toPlaceposDist < 12 || toKickPosDist < 12) // 接近切入点
		{
			nearBall = 1;
			task.target_pos = kickPos;
			task.orientate = toGoalDir;
			task.needCb = true;
		}
	}


	/*防止 多次反复 短距离跟球踢球造成二次触球*/
	if (toKickPosDist > 15)
	{
		i = 0;
		nearBall = 0;
	}
	else{
		nearBall = 1;
	}

	/*逼近踢球点*/
	if (nearBall)//从 placePos附近 逼近kickPos ，准备射球
	{
		task.target_pos = kickPos;
		task.orientate = toGoalDir;
		task.needCb = true;
	}

	/* 最后的踢球 */
	if (toKickPosDist < 10)   
	{
		task.target_pos = kickPos;
		task.orientate = toGoalDir;
		task.needCb = true;
		if (fabs(r2b - toGoalDir) < PI / 8 && toBallDist < MAX_ROBOT_SIZE)
		{
			++i;
		}
		if (i > 3) //角度误差不大， 延迟结束， 射门
		{
			i = 4;
			nearBall = 0;
			task.needCb = false;
			task.needKick = true;
			task.kickPower = my_kick_power;
		}
	}///

	return task;
}






/*-----------------------------------------------------------------------------------*/


 

/*获取我方接球队员 ID*/
int GetReceverID(const WorldModel *model, int robot_id){
	int  receiver_id = -100;

	for (int i = 0; i < 6; i++)
	{
		if (i == robot_id || i == model->get_our_goalie())
			continue;
		if (model->get_our_exist_id()[i])
			receiver_id = i;
	}
	return receiver_id;
}



//限定大小阈值
float my_limite(float x, float max, float min)
{
	if (x - max> 0)
	{
		x = max;
	}
	else if (min - x > 0)
	{
		x = min;
	}
	return x;
}


//atan2f 超越PI 与 -PI  时重新更新
float atan2fCorrect(float dir)
{
	float result = dir;
	if (result > PI)
	{
		return (result - PI - PI);
	}
	else if (result < -PI)
	{
		return (result + PI + PI);
	}
	else
	{
		return result;
	}
}


/*atan2f  角度 转化为 【0 ， 2 PI】 角度*/
float DIR(float d)
{
	d = (d >= 0 ? d : (d + PI + PI));
	return d;
}

/*绕圆周 转动时 每次转移时调整的 弧度/角度 */
/* 转动需要的 角度 ， 球->球员， 球->目标点, 转动角【 18°  ， 60°】， 36°较好*/
float RunOnCircleDir(float b2r, float b2g, float DetAngle)
{
	//   我为蓝方视角
	if (DetAngle > 0.33*PI || DetAngle < 0.1*PI)
	{
		DetAngle = PI / 5;
	}
	//DetAngle= my_limite( DetAngle, 0.33*PI, 0.1*PI );

	float dir;
	if (b2r >= b2g && fabs(b2r - b2g) <= PI)
	{
		dir = b2r + DetAngle; //顺时针
	}
	else if (b2r < b2g && fabs(b2r - b2g) <= PI)
	{
		dir = b2r - DetAngle; //逆时针
	}
	else if (b2r >= b2g && fabs(b2r - b2g) >= PI)
	{
		dir = b2r - DetAngle;
	}
	else if (b2r < b2g && fabs(b2r - b2g) > PI)
	{
		dir = b2r + DetAngle;
	}
	return dir;
}


//atanf2 角度反转
float Reverse_Dir(float dir)
{
	if (dir >= 0)
	{
		dir -= PI;
	}
	else
	{
		dir += PI;
	}
	return dir;
}


/* 跑向圆周时 应该到达的 位置角度值 */
/* 转动需要的 角度 ， 球->球员， 球->目标点*/
float RunToCircleDir(float b2r, float b2g)
{
	//   我为蓝方视角
	//不需要调整 直接跑过去
	if (fabs(b2r - b2g) >= 0.60*PI && fabs(b2r - b2g) <= 1.40 * PI)
	{
		return b2r;
	}

	//需要调                                      
	if (b2r > b2g && fabs(b2r - b2g) < 0.60 * PI)//
	{
		return b2g + PI - 0.4*PI;
	}
	else if (b2r < b2g && fabs(b2r - b2g) < 0.60 * PI)
	{
		return b2g + PI + 0.4*PI;
	}

	else if (b2r > b2g && fabs(b2r - b2g) > 1.40 * PI)//
	{
		return b2g + PI + 0.4*PI;
	}
	else if (b2r < b2g && fabs(b2r - b2g) > 1.40 * PI)
	{
		return b2g + PI - 0.4*PI;
	}

	else {
		return b2r;
	}

}