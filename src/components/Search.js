import React from 'react';
import { Container, Row, Col, Form } from 'react-bootstrap';

const Search = () => {
    return (
        <header style={{ display: 'flex', alignItems: 'center' }}>
            <Container>
                <Row className="justify-content-center">
                    <Col md={8} lg={6} className="d-flex flex-column justify-content-center">
                        <h2 className="text-center mb-3">Search it. Explore it. Buy it.</h2>
                        <Form>
                            <Form.Group controlId="searchQuery">
                                <Form.Control
                                    type="text"
                                    placeholder="Enter an address, neighborhood, city, or ZIP code"
                                    className="header__search"
                                />
                            </Form.Group>
                        </Form>
                    </Col>
                </Row>
            </Container>
        </header>
    );
}

export default Search;
