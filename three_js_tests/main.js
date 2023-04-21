// example code from https://threejs.org/docs/index.html#manual/en/introduction/Creating-a-scene
import * as THREE from 'three'
import Stats from 'stats.js'

// create and add renderer to document
const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.shadowMap.enabled = true; // enables shadows
document.body.appendChild(renderer.domElement);

// fps counter using stats
const stats = new Stats()
stats.showPanel(0) // 0: fps, 1: ms, 2: mb, 3+: custom
document.body.appendChild(stats.dom)

// instantiate scene
const scene = new THREE.Scene();

// camera
const fov = 75;
const aspect_ratio = window.innerWidth / window.innerHeight;
const near = 0.1;
const far = 1000;
const camera = new THREE.PerspectiveCamera(fov, aspect_ratio, near, far);
// helper (debug) camera
const camera_helper = new THREE.CameraHelper(camera);
scene.add(camera_helper);

// create cube
const cube_geometry = new THREE.BoxGeometry(1, 1, 1);
const cube_material = new THREE.MeshStandardMaterial({ color: 0x22ff22 }); // greenish
const cube = new THREE.Mesh(cube_geometry, cube_material);
cube.castShadow = true;
scene.add(cube);

// create ground plane
const plane_geometry = new THREE.PlaneGeometry(100, 100);
const plane_material = new THREE.MeshStandardMaterial({ color: 0x2222ff, side: THREE.DoubleSide });
const plane = new THREE.Mesh(plane_geometry, plane_material);
plane.rotation.x = Math.PI / 2;
plane.position.set(0, -1, 0);
plane.receiveShadow = true;
scene.add(plane);

// add point light
const point_light = new THREE.PointLight(0xffffff, 1, 100); // redish
point_light.position.set(3, 10, 5);
point_light.castShadow = true;
scene.add(point_light);

// add ambient light
const ambient_light = new THREE.AmbientLight(0xffffff, 1/10, 100); // redish
scene.add(ambient_light);

// move camera because else the camera is inside the cube
camera.position.z = 5;

// render loop
function animate() {
    // start of fps counter
    stats.begin();

    requestAnimationFrame(animate);

    cube.rotation.x += 0.01;
    cube.rotation.y += 0.01;


    // render scene
    renderer.render(scene, camera);

    // end of fps counter
    stats.end();
}
animate();