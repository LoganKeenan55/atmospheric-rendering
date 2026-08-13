shader_type sky;

uniform vec3 cameraPosition;

const float atmosphereHeight = 1000.0f; //height of atmosphere
const float scaleHeight = 200.0f;      //how fast atmosphere gets thinner

const int steps = 64; //how many points sampled per ray
const float stepSize = 100.0f; //how spaced out the samples are

const float kr = 0.0025f; //scattering constant

const vec3 lamda = vec3(0.700f, 0.540f, 0.49f); //colors in micrometers

const vec3 scatteringCoefficient = kr / pow(lamda, vec3(4.0f)); //K(lamda)

const vec3 rayleighCoefficient = (4.0f*PI) * scatteringCoefficient;


void sky() {

     vec3 rayDirection = EYEDIR;

     float distance = 0.0f; //distance traveled along ray
     float outScatterAcc = 0.0f;


     for(int i = 0; i < steps; i++){
          vec3 sample = cameraPosition + rayDirection * distance;

          float height = sample.y;

          float sampleOutScatter = 0.0f;

          if (height >= 0.0 && height <= atmosphereHeight) {
               sampleOutScatter = exp(-height / scaleHeight); //density at height
          }

          outScatterAcc += sampleOutScatter * stepSize; //accumulate outscatter along ray

          distance += stepSize;
     }

     vec3 outScatter = outScatterAcc / (float(steps) * stepSize) * rayleighCoefficient; //ammount of light scattered
     vec3 transmittance = exp(-outScatter); //fraction of light that survives
     
     COLOR = transmittance;
}
