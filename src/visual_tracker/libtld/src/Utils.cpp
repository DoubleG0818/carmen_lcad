/*
 * Copyright � 2011 Paul Nader 
 *
 * This file is part of QOpenTLD.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "Utils.hpp"

void loadImage(const cv::Mat& mat, IplImage *image)
{
	int widthStep = image->widthStep;
	int N = image->width; // width
	int M = image->height; // height

	if (N == 0 || M == 0)
	{
		printf("Input image error\n");
		return;
	}

	for (int i=0; i<M; i++)
		for (int j=0; j<N; j++) 
			image->imageData[j+widthStep*i] = mat.at<unsigned>(i,j);
}

double fix(double d)
{
	if (d > 0) return cvFloor(d);
	return cvCeil(d);
}
