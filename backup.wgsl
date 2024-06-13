    var pixel_coor:vec2<f32>=vec2<f32>(position.x/Resolution.y,(Resolution.y-position.y)/Resolution.y);//convert to the origin at left bottom
    let joint: JointClass = initializeJoint();

    update_angle_parameter();

    
    var clikcPos=MouseClick();
    var ClickCircle=Circle(vec2<f32>(clikcPos),click_radius);
    var floatPos=MouseFloat();
    var FloatCircle=Circle(vec2<f32>(floatPos),float_radius);
    //FK test:
    angArray[0]=get_angle_parameter_0();
    GlobalAngArray[0]=angArray[0];
    angArray[1]=get_angle_parameter_1();


    // IK test:
    let initial_guess = vec2<f32>(angArray[0], angArray[1]);
    let tol: f32 = 1e-6;
    let max_iter: i32 = 100;
    let result = inverse_kinematics(clikcPos, initial_guess, tol, max_iter);
    angArray[0]=result.x;
    GlobalAngArray[0]=angArray[0];
    angArray[1]=result.y;
    floatBuffer[0] = angArray[0];
    floatBuffer[1] = angArray[1];

    var joints_flag=FK_DrawJoints(joint,pixel_coor);
    var click_flag=DrawCircle(ClickCircle,pixel_coor,i32(1));
    var float_flag=DrawCircle(FloatCircle,pixel_coor,i32(2));
    if(joints_flag.w>=1.0){
      return joints_flag;
    }else if(click_flag.w>=1.0){
      return click_flag;
    }else if(float_flag.w>=1.0){
      return float_flag;
    }

    return vec4<f32>(BLACK,1.0);








fn pseudo_inverse(J: mat2x2<f32>) -> mat2x2<f32> {
    let det = J[0][0] * J[1][1] - J[0][1] * J[1][0];
    if det == 0.0 {
        // singularity
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
    
