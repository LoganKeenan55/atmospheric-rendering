shader_type sky;

uniform vec3 cameraPosition;
uniform vec3 sunDirection;

const float atmosphereHeight = 10000.0f; //height of atmosphere
const float scaleHeight = 1000.0f;      //how fast atmosphere gets thinner

const int steps = 32; //how many points sampled per ray
const int inSteps = 16; //how many points sampled per single scatter ray

//outScatter
const vec3 lamda = vec3(0.700f, 0.540f, 0.49f); //colors in micrometers
const float kr = 0.0025f; //scattering constant
const vec3 scatteringCoefficient = kr / pow(lamda, vec3(4.0f)); //K(lamda)
const vec3 rayleighCoefficient = ((4.0f*PI) * scatteringCoefficient) / 1000.0f; //convert to km

const float twilightDuration = 0.1f;

float distanceToAtmosphere(vec3 start, vec3 direction){
     float target = direction.y >= 0.0f ? atmosphereHeight : 0.0f;
     
     float t = (target - start.y) / direction.y;

     return t; 
     //min(t,150000.0f) to compensate for flat world
}

vec3 getOutScatter(vec3 start, vec3 direction, float maxDistance){
     float distance = 0.0f; //distance traveled along ray
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
     
     vec3 sunDirForScatter = sunDirection;
     sunDirForScatter.y = max(sunDirection.y, 0.001f);

     for(int i = 0; i < inSteps; i++){
          vec3 sample = start + direction * distance;

          float height = sample.y;

          if (height >= 0.0 && height <= atmosphereHeight) {
               float localDensity = exp(-height / scaleHeight);

               //how much sunlight makes it to sample point
               vec3 sunOutScatter = getOutScatter(sample, sunDirection, distanceToAtmosphere(sample, sunDirForScatter));
               //how much sunlight makes it to camera
               vec3 viewOutScatter = getOutScatter(start, direction, distance);
               //combine trip sun -> sample -> camera
               vec3 totalAttenuation = exp(-(sunOutScatter + viewOutScatter));

               vec3 sampleInScatter = localDensity * totalAttenuation;

               inScatterAcc += sampleInScatter * stepSize;
          }

          distance += stepSize;
     }

     return inScatterAcc * rayleighCoefficient * phase;
}


void sky() {

     vec3 rayDirection = EYEDIR;

     //reflect ray direction on lower half of screen
     vec3 scatterDirection = rayDirection;
     if (scatterDirection.y < 0.0f) {
          scatterDirection.y = -scatterDirection.y;
     }
     
     float cosTheta = dot(scatterDirection, sunDirection);
     float phase = 0.7f * (1.0f + (cosTheta * cosTheta));

     //slightly dims horizon
     vec3 inScatter = getInScatter(cameraPosition,scatterDirection, phase);
     float horizonFactor = mix(0.5f, 1.0f, smoothstep(0.0, 0.15f, abs(rayDirection.y)));
     inScatter *= horizonFactor;

     //adds extra time to sunset before sun is completely set
     float twilightAmount = smoothstep(-twilightDuration, 0.0f, sunDirection.y);
     inScatter *= twilightAmount;

     //water
     if (rayDirection.y < 0.0f) {
          COLOR = inScatter * vec3(0.1, 0.1, 0.15);
     }
     
     //sun circle
     else if (dot(scatterDirection, sunDirection) > 0.999f) {
          COLOR = vec3(1.0);
     }

     //sky
     else {
          //glow around sun
          float glow = smoothstep(0.996f, 0.9999f, dot(scatterDirection, sunDirection)) * 0.30f;
          COLOR = inScatter + vec3(1.0) * inScatter * glow;
     }
}