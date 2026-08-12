shader_type sky;

uniform vec3 cameraPosition;

const float atmosphereHeight = 1000.0f; //height of atmosphere
const float scaleHeight = 200.0f;      //how fast atmosphere gets thinner

const int steps = 64; //how many points sampled per ray
const float stepSize = 100.0f; //how spaced out the samples are

void sky() {

     vec3 rayDirection = EYEDIR;

     float distance = 0.0f; //distance traveled along ray
     float totalDensity = 0.0f;


     for(int i = 0; i < steps; i++){
          vec3 point = cameraPosition + rayDirection * distance;

          float height = point.y;

          float density = 0.0;

          
          density = exp(-height / scaleHeight); //atmospheric density at point

          totalDensity += density * stepSize; //accumulate atmosphere along ray

          distance += stepSize;
     }

     float visualization = totalDensity / (float(steps) * stepSize); //visualize atmospheric density

     COLOR = vec3(visualization);
}
