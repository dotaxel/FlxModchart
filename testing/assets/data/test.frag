in vec2 vUV;
out vec4 FragColor;

uniform float iTime;

void main() {
    vec2 uv = vUV;
    uv.x += sin(uv.y * 15 + (iTime)) * 0.08;
    vec4 color = texture(tex, uv);

    FragColor = color;
}