var<private> RED:vec3<f32>=vec3(209.0, 99.0, 71.0)/255.0;
var<private> BLUE:vec3<f32>=vec3(135,206,235)/255.0;
var<private> BLACK:vec3<f32>=vec3(0,0,0)/255.0;
var<private> BROWN:vec3<f32>=vec3(220,74,43)/255.0;
var<private> DEEPGREEN:vec3<f32>=vec3(104, 140, 27)/255.0;
var<private> SHADOWGREEN:vec3<f32>=vec3(165,233,154)/255.0;
const BAR_NUM: i32 = 2;
const click_radius: f32 = 0.005;
const float_radius: f32 = 0.009;

struct Circle {
  center: vec2<f32>,
  radius:f32
}
struct Rectangle {
  center: vec2<f32>,
  side1:f32,
  side2:f32,
  theta:f32// this should be in radians
}

// define some info for the joint
var<private> jointRadius:f32=0.01;
var<private> jointOrigin:vec2<f32>=vec2<f32>(0.5, 0.0);
var<private> sidesLen=array<f32,BAR_NUM>(0.3,0.3);
var<private> posArray:array<vec2<f32>,BAR_NUM>;// save the position information for the joint
var<private> angArray:array<f32,BAR_NUM>;// save the pose(angle) information for the joint , this is the local angle information
var<private> GlobalAngArray:array<f32,BAR_NUM>;// This is the global angle information
struct JointClass{
  jointNum:i32,//the number of the joint
  origin:vec2<f32>,
  radius:f32,
  barSideLen:array<f32,BAR_NUM>//storage the side length for all the bars
}
fn initializeJoint() -> JointClass {
    posArray=array(jointOrigin,jointOrigin);
    angArray=array(-4.36,52.330);
    GlobalAngArray=array(0.0,0.0);
    return JointClass(
        BAR_NUM,
        jointOrigin,
        jointRadius,
        sidesLen
    );
}

fn DrawCircle(circle:Circle,pos:vec2<f32>,colorID:i32)-> vec4<f32>{
    var len:f32=distance(circle.center,pos);
    if (colorID==0){// joint
      if (len<=circle.radius){
          return vec4<f32>(RED,2.0);
      }
    }else if (colorID==1){// target point
      if (len<=circle.radius){
          return vec4<f32>(DEEPGREEN,2.0);
      }
    }else if (colorID==2){// Float point
      if (len<=circle.radius){
          return vec4<f32>(SHADOWGREEN,2.0);
      }
    }

    
    return vec4<f32>(BLACK,0.0);
}
fn DrawRectangle(rect:Rectangle,pos:vec2<f32>)-> vec4<f32>{
    let theta_radians:f32=rect.theta*3.1415926/180;
    var dir1:vec2<f32>=vec2<f32>(cos(theta_radians),sin(theta_radians));
    var dir2:vec2<f32>=vec2<f32>(-sin(theta_radians),cos(theta_radians));
    var dir3:vec2<f32>=vec2<f32>(sin(theta_radians),-cos(theta_radians));
    let side2=rect.side2/2.0;
    let side1=rect.side1;
    var posVector=pos-rect.center;
    var LenDIR1=dot(posVector,dir1);//judge if the point in the same direction
    var LenDIR2=dot(posVector,dir2);
    var LenDIR3=dot(posVector,dir3);

    if((LenDIR1<=side1)&&(LenDIR1>=0)){
        if(((LenDIR2>=0)&&(LenDIR2<=side2))||((LenDIR3>=0)&&(LenDIR3<=side2))){
            return vec4<f32>(BLUE,1.0);
        }
    }
    return vec4<f32>(BLACK,0.0);
}
//input: a Joints class
//output: the color
fn FK_DrawJoints(joints:JointClass,pos:vec2<f32>)-> vec4<f32>{
    let barNum=joints.jointNum;
    let circleNum=barNum+1;
    let objectNum=circleNum+barNum;
    var out_color:vec4<f32>;
    out_color=vec4<f32>(BLACK,0.0);//the last flag denote the layer 0 for black, 1 for rectangle ,2 for circle

    for (var i: i32 = 0; i < objectNum; i++) {
        var object_id=i%2;// 0-> circle 1->rectangle
        var cur_pos:vec2<f32>;
        var pre_pos:vec2<f32>;
        var cur_angle:f32;
        var pre_angle:f32;
        var pre_sidelength:f32;
        var cur_sidelength:f32;
        var joint_index:i32;// the index for joint id 0 or 1
        joint_index=i/2;
        if(i==0||i==1){// the first one, the original one
          cur_pos=posArray[joint_index];
          cur_angle=GlobalAngArray[joint_index];
          cur_sidelength=joints.barSideLen[joint_index];
        }else{
          //calculate the position and angle
          pre_pos=posArray[joint_index-1];
          pre_angle=GlobalAngArray[joint_index-1];
          pre_sidelength=joints.barSideLen[joint_index-1];
          cur_sidelength=joints.barSideLen[joint_index];
          var pre_rads=radians(pre_angle);
          var pre_dir=vec2<f32>(cos(pre_rads),sin(pre_rads));

          cur_pos=pre_pos+pre_dir*pre_sidelength;
          cur_angle=pre_angle+angArray[joint_index];// global angles
          posArray[joint_index]=cur_pos;
          GlobalAngArray[joint_index]=cur_angle;
        }
        if(object_id==0){
        // for circle
          var localCircle=Circle(vec2<f32>(cur_pos),joints.radius);
          var local_out_color=DrawCircle(localCircle,pos,i32(0));
          if(local_out_color.w>=1.0){
            out_color=local_out_color;
          }
        }else{
        // for rectangle
          var localRect=Rectangle(vec2<f32>(cur_pos),cur_sidelength,2*joints.radius,cur_angle);
          var local_out_color=DrawRectangle(localRect,pos);
          if(local_out_color.w>=1.0&&(out_color.w!=2)){// only update when the previous color is not from the circle
            out_color=local_out_color;
          }
        }
    }
    return out_color;
}
fn update_angle_parameter(){
  if(Key == 65) // key==A
  {
    var theta = floatBuffer[0];
    theta = theta + 0.05;
    if(theta>=360) 
    {
       theta = 0.0;
    }  
    floatBuffer[0] = theta;
  }
  if(Key == 68) // key==D
  {
    var theta = floatBuffer[0];
    theta = theta - 0.05;
    if(theta<=0) 
    {
       theta = 360.0;
    }  
    floatBuffer[0] = theta;
  }

  if(Key == 74) // key==J
  {
    var theta = floatBuffer[1];
    theta = theta + 0.05;
    if(theta>=360) 
    {
       theta = 0.0;
    }  
    floatBuffer[1] = theta;
  }
  if(Key == 76) // key==L
  {
    var theta = floatBuffer[1];
    theta = theta - 0.05;
    if(theta<=0) 
    {
       theta = 360.0;
    }  
    floatBuffer[1] = theta;
  }
}
fn get_angle_parameter_0()->f32{
  return floatBuffer[0];
}
fn get_angle_parameter_1()->f32{
  return floatBuffer[1];
}

fn MouseClick()->vec2<f32>{
  var ClickMousePos:vec2<f32>=vec2<f32>(Mouse.z/Resolution.y,(Resolution.y-Mouse.w)/Resolution.y);
  return ClickMousePos;
}
fn MouseFloat()->vec2<f32>{
  var FloatMousePos:vec2<f32>=vec2<f32>(Mouse.x/Resolution.y,(Resolution.y-Mouse.y)/Resolution.y);
  return FloatMousePos;
}

//--------------------------------------------------------------
//This is for inverse Kinematics
// 定义常量
var<private> L1: f32 = 0.3;
var<private> L2: f32 = 0.3;
var<private> x_o: f32 = 0.5;
var<private> y_o: f32 = 0.0;

// 正向运动学函数
fn forward_kinematics(theta1: f32, theta2: f32) -> vec2<f32> {
    let x = x_o + L1 * cos(theta1) + L2 * cos(theta1 + theta2);
    let y = y_o + L1 * sin(theta1) + L2 * sin(theta1 + theta2);
    return vec2<f32>(x, y);
}

// 雅可比矩阵计算
fn jacobian(theta1: f32, theta2: f32) -> mat2x2<f32> {
    let J11 = -L1 * sin(theta1) - L2 * sin(theta1 + theta2);
    let J12 = -L2 * sin(theta1 + theta2);
    let J21 = L1 * cos(theta1) + L2 * cos(theta1 + theta2);
    let J22 = L2 * cos(theta1 + theta2);
    return mat2x2<f32>(vec2<f32>(J11, J12), vec2<f32>(J21, J22));
}

// 矩阵求伪逆
fn pseudo_inverse(J: mat2x2<f32>) -> mat2x2<f32> {
    let det = J[0][0] * J[1][1] - J[0][1] * J[1][0];
    if det == 0.0 {
        // 处理奇异矩阵情况（这里简单返回单位矩阵）
        return mat2x2<f32>(vec2<f32>(1.0, 0.0), vec2<f32>(0.0, 1.0));
    } else {
        let inv_det = 1.0 / det;
        let J_inv = mat2x2<f32>(
            vec2<f32>(J[1][1] * inv_det, -J[0][1] * inv_det),
            vec2<f32>(-J[1][0] * inv_det, J[0][0] * inv_det)
        );
        return J_inv;
    }
}

// 逆向运动学求解函数
fn inverse_kinematics(target_pos: vec2<f32>, initial_guess: vec2<f32>, tol: f32, max_iter: i32) -> vec2<f32> {
    var theta = initial_guess;
    for (var i: i32 = 0; i < max_iter; i = i + 1) {
        let current_pos = forward_kinematics(theta[0], theta[1]);
        let error = target_pos - current_pos;
        if (length(error) < tol) {
            break;
        }
        let J = jacobian(theta[0], theta[1]);
        let J_inv = pseudo_inverse(J);
        let dtheta = J_inv * error;
        theta = theta + dtheta;
    }
    return theta;
}

//----------------------------------------------------------------------------



const Frequency: i32 = 2;

@fragment
fn main(@builtin(position) position: vec4<f32>) -> @location(0) vec4<f32> {

  if (floor(position.x)==f32(10)&&floor(position.y)==f32(10)){
      var frameID:i32=intBuffer[0];
      frameID=(frameID+1)%2;
      intBuffer[0]=frameID;
  }
  
  return vec4<f32>(1,1,1,1);
}

//    let Rect_Flag=DrawRectangle(jointBar,pixel_coor);
//    let Cricle_Flag=DrawCircle(jointCircle,pixel_coor);

//    if(Cricle_Flag.w==1.0){// decide which should the the top, circle default
//      return Cricle_Flag;
//    }else if(Rect_Flag.w==1.0){
//      return Rect_Flag;
//    }






