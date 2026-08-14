shader_type sky;

uniform vec3 cameraPosition;
uniform vec3 sunDirection;

const float atmosphereHeight = 10000.0f; //height of atmosphere
const float scaleHeight = 100.0f;      //how fast atmosphere gets thinner

const int steps = 64; //how many points sampled per ray
const int inSteps = 16;

//outScatter
const vec3 lamda = vec3(0.700f, 0.540f, 0.49f); //colors in micrometers
const float kr = 0.0025f; //scattering constant
const vec3 scatteringCoefficient = kr / pow(lamda, vec3(4.0f)); //K(lamda)
const vec3 rayleighCoefficient = ((4.0f*PI) * scatteringCoefficient) / 1000.0f; //convert to km


float distanceToAtmosphere(vec3 start, vec3 direction){
     float target = direction.y >= 0.0f ? atmosphereHeight : 0.0f;
     
     float t = (target - start.y) / direction.y;
     return t;
}

vec3 getOutScatter(vec3 start, vec3 direction, float maxDistance){
     
     float distance = 0.0f;
     vec3 outScatterAcc = vec3(0.0f);

     float stepSize = maxDistance / float(steps);

     for(int i = 0; i < steps; i++){
          vec3 samplePos = start + direction * distance;
          float height = samplePos.y;

          float sampleOutScatter = 0.0f;
          if (height >= 0.0 && height <= atmosphereHeight) {
               sampleOutScatter = exp(-height / scaleHeight);
          }

          outScatterAcc += sampleOutScatter * stepSize;
          distance += stepSize;
     }

     return outScatterAcc * rayleighCoefficient;
}

vec3 getInScatter(vec3 start, vec3 direction, float phase){
     float distance = 0.0f; //distance traveled along ray
     vec3 inScatterAcc = vec3(0.0f);

     float stepSize = distanceToAtmosphere(start, direction) / float(inSteps);

     for(int i = 0; i < inSteps; i++){
          vec3 sample = start + direction * distance;

          float height = sample.y;

          if (height >= 0.0 && height <= atmosphereHeight) {
               float localDensity = exp(-height / scaleHeight); //density at height

               //sunlight reaching sample
               vec3 sunOutScatter = getOutScatter(sample, sunDirection, distanceToAtmosphere(sample, sunDirection)); //how much sunlight makes it down to this sample point
               vec3 viewOutScatter = getOutScatter(start, direction, distance); //how much sunlight makes it to camera

               vec3 totalAttenuation = exp(-(sunOutScatter + viewOutScatter)); //combine trip sun -> sample -> camera

               vec3 sampleInScatter = localDensity * totalAttenuation;

               inScatterAcc += sampleInScatter * stepSize;
          }

          distance += stepSize;
     }

     return inScatterAcc * rayleighCoefficient * phase;
}


vec3 waterColor(){
     return vec3(0.1, 0.1, 0.15);
}

void sky() {

     vec3 rayDirection = EYEDIR;

     vec3 scatterDirection = rayDirection;
     if (scatterDirection.y < 0.0f) {
          scatterDirection.y = -scatterDirection.y;
     }

     float cosTheta = dot(scatterDirection, sunDirection);
     float phase = 0.75f * (1.0f + (cosTheta * cosTheta));

     vec3 inScatter = getInScatter(cameraPosition, scatterDirection, phase);

     //water
     if (rayDirection.y < 0.0f) {
          /*if (cosTheta > 0.999f) {
               COLOR = vec3(1.0) * 0.80f;
          } else {
          */
               COLOR = inScatter * waterColor();
         // }
     }
     //sun is set
     else if (sunDirection.y < 0.0) {
          COLOR = vec3(0.0f);
     }
     //sun circle
     else if (cosTheta > 0.999f) {
          COLOR = vec3(1.0);
     }
     //sky
     else {
          COLOR = inScatter;
     }
}