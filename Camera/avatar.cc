#include "tools.h"
#include "avatar.h"
#include "scene.h"

Avatar::Avatar(const std::string &name, Camera * cam, float radius) :
	m_name(name), m_cam(cam), m_walk(false) {
	Vector3 P = cam->getPosition();
	m_bsph = new BSphere(P, radius);
}

Avatar::~Avatar() {
	delete m_bsph;
}

void Avatar::setCamera(Camera *thecam) {
	m_cam = thecam;
}

Camera *Avatar::getCamera() const {
	return m_cam;
}


bool Avatar::walkOrFly(bool walkOrFly) {
	bool walk = m_walk;
	m_walk = walkOrFly;
	return walk;
}

bool Avatar::getWalkorFly() const {
	return m_walk;
}

//
// AdvanceAvatar: advance 'step' units
//
// @@ TODO: Change function to check for collisions. If the destination of
// avatar collides with scene, do nothing.
//
// Return: true if the avatar moved, false if not.

bool Avatar::advance(float step) {
	Node *rootNode = Scene::instance()->rootNode();
	if (m_walk)
		m_cam->walk(step);
	else
		m_cam->fly(step);

	bool moved = true;

	m_bsph->setPosition(m_cam->getPosition());
	const Node *collide = rootNode->checkCollision(m_bsph);
	if (collide!=0) {
		if (m_walk) m_cam->walk(-step);
		else m_cam->fly(-step);
				
		m_bsph->setPosition(m_cam->getPosition());
		moved = false;
	}
	return moved;
}

void Avatar::leftRight(float angle) {
	if (m_walk)
		m_cam->viewYWorld(angle);
	else
		m_cam->yaw(angle);
}

void Avatar::upDown(float angle) {
	m_cam->pitch(angle);
}

void Avatar::panX(float step) {
	m_cam->panX(step);
}

void Avatar::panY(float step) {
	m_cam->panY(step);
}

void Avatar::print() const { }
