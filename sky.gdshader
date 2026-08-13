shader_type sky;

uniform vec3 cameraPosition;
uniform vec3 sunDirection;

const float atmosphereHeight = 10000.0f; //height of atmosphere
const float scaleHeight = 2000.0f;      //how fast atmosphere gets thinner

const int steps = 64; //how many points sampled per ray
const int inSteps = 16;
//outScatter
const vec3 lamda = vec3(0.700f, 0.540f, 0.49f); //colors in micrometers
const float kr = 0.0025f; //scattering constant
const vec3 scatteringCoefficient = kr / pow(lamda, vec3(4.0f)); //K(lamda)
const vec3 rayleighCoefficient = ((4.0f*PI) * scatteringCoefficient) / 1000.0f; //convert to km

vec3 getOutScatter(vec3 start, vec3 direction){
     
     float distance = 0.0f; //distance traveled along ray
     vec3 outScatterAcc = vec3(0.0f);

     float stepSize = atmosphereHeight / float(steps);

     for(int i = 0; i < steps; i++){
          vec3 sample = start + direction * distance;

          float height = sample.y;

          float sampleOutScatter = 0.0f;

          if (height >= 0.0 && height <= atmosphereHeight) {
               sampleOutScatter = exp(-height / scaleHeight); //density at height
          }

          outScatterAcc += sampleOutScatter * stepSize; //accumulate outscatter along ray

          distance += stepSize;
     }

     return outScatterAcc* rayleighCoefficient; //ammount of light scattered
}

vec3 getInScatter(vec3 start, vec3 direction, float phase){
     float distance = 0.0f; //distance traveled along ray
     vec3 inScatterAcc = vec3(0.0f);

     float stepSize = atmosphereHeight / float(inSteps);

     for(int i = 0; i < inSteps; i++){
          vec3 sample = start + direction * distance;

          float height = sample.y;

          if (height >= 0.0 && height <= atmosphereHeight) {
               float localDensity = exp(-height / scaleHeight); //density at height

               //sunlight reaching sample
               vec3 sunOutScatter = getOutScatter(sample,sunDirection);
               vec3 sunAttenuation = exp(-sunOutScatter);

               vec3 sampleInScatter = localDensity * sunAttenuation;

               inScatterAcc += sampleInScatter * stepSize;
          }

          distance += stepSize;
     }

     return inScatterAcc * rayleighCoefficient * phase;
}


void sky() {

     vec3 rayDirection = EYEDIR;

     float cosTheta = dot(rayDirection, sunDirection);
     float phase = 0.75f * (1.0f + (cosTheta * cosTheta));

     vec3 outScatter = getOutScatter(cameraPosition,rayDirection);
     vec3 transmittance = exp(-outScatter); //fraction of light that survives

     vec3 inScatter = getInScatter(cameraPosition,rayDirection,phase);
     COLOR = inScatter;
}


