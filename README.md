# UESTC Lab
This is the demo for forward kinematic and inverse kinematics.

## FK(Forward kinematic)
1. scene graph rendering

## Buffer Usage
### 1. float buffer
FloatBuffer[0]: angle 1 for one joint 1

FloatBuffer[1]: angle 2 for one joint 2

...

save 10 space for more joint angles

From FloatBuffer[10]: start to save the Jacobian matrix， In this case, we have two angles

### 2. Inverse process
Since we need to calculate the jacobian first, then transform,so we need to define two frame

Use the IntBuffer to define different frame, then iterate the frame between 0/1.

We calcule the jacobian at frame 0 and use it at frame 1

If pixel.xy==(0,0) and frame=0, calculate the jacobian

    frame=(frame+1)%2

else if frame==1, render the result

#### 2.1 IntBuffer
IntBuffer[0]: mode of the program, FK or IK, based on the key space

IntBuffer[1]: frame number, control for the IK process

"""
 if (floor(position.x)==f32(10)&&floor(position.y)==f32(10)){
          var frameID:i32=intBuffer[1];
          frameID=(frameID+1)%50;
          intBuffer[1]=frameID;
      }
      if(intBuffer[1]<=1){// calculate the solution
        let initial_guess = vec2<f32>(angArray[0], angArray[1]);
        let tol: f32 = 1e-6;
        let max_iter: i32 = 100;
        clikcPos=MouseClick();
        let result = inverse_kinematics(clikcPos, initial_guess, tol, max_iter);
        floatBuffer[10]=result.x*180/3.1415926;
        floatBuffer[11]=result.y*180/3.1415926;
      }else if(intBuffer[1]>=2){

"""



